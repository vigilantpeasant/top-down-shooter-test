extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@export var bullet_scene: PackedScene
@onready var health_bar = $Healthbar
@onready var damage_bar = $Healthbar/DamageBar
@onready var navigation_agent = $NavigationAgent2D

const speed = 100
var health = 50
var max_health = 50
var player: Node2D
var can_shoot = true
var rate_of_fire: float = 0.8
var miss_chance: float = 0.6
var max_miss_angle: float = 15.0
var detection_range: float = 300.0

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	damage_bar.max_value = max_health
	damage_bar.value = health
	
	if health == max_health:
		health_bar.visible = false
		damage_bar.visible = false

func take_damage():
	health_bar.visible = true
	damage_bar.visible = true
	health -= 15
	health_bar.value = health
	get_tree().create_timer(0.5).timeout.connect(_update_damage_bar)
	if health <= 0:
		queue_free()
	else:
		see_player()

func see_player():
	var player_node = find_player_node(get_tree().get_root())
	if player_node != null:
		player = player_node
		animated_sprite_2d.play("weapon")

func find_player_node(node):
	if node.has_node("Player"):
		return node.get_node("Player")
	
	for child in node.get_children():
		var result = find_player_node(child)
		if result != null:
			return result
	
	return null

func _update_damage_bar():
	if damage_bar.value > health_bar.value:
		damage_bar.value -= 1
		if damage_bar.value > health_bar.value:
			get_tree().create_timer(0.05).timeout.connect(_update_damage_bar)

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		animated_sprite_2d.play("weapon")
		player = body

func _process(_delta):
	if player != null:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= detection_range:
			animated_sprite_2d.look_at(player.global_position)
			if can_shoot:
				shoot()
		else:
			follow_player()
	else:
		player = null

func follow_player():
	if player != null:
		navigation_agent.set_target_position(player.global_position)
		if navigation_agent.is_target_reached():
			velocity = Vector2.ZERO
		else:
			velocity = navigation_agent.get_next_path_position() - global_position
			velocity = velocity.normalized() * speed
		move_and_slide()
		animated_sprite_2d.look_at(player.global_position)

func shoot():
	can_shoot = false
	var miss = randf() < miss_chance
	var angle_offset = 0.0
	if miss:
		angle_offset = deg_to_rad(randf_range(-max_miss_angle, max_miss_angle))
	var bullet = bullet_scene.instantiate() as Area2D
	var marker_position = $AnimatedSprite2D/Marker2D.global_position
	bullet.position = marker_position
	bullet.rotation = (player.global_position - marker_position).angle() + angle_offset
	get_parent().add_child(bullet)
	await get_tree().create_timer(rate_of_fire).timeout
	can_shoot = true
