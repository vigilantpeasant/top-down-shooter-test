extends CharacterBody2D

@export var bullet_scene: PackedScene
@onready var health_bar = $Healthbar
@onready var damage_bar = $Healthbar/DamageBar
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var navigation_agent = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D

const SPEED = 120
const MISS_CHANGE = 0.5
const MAX_MISS_CHANGE = 10.0
const DETECTION_RANGE = 350.0
const MAX_AMMO = 15

var health = 50
var max_health = 50
var player: Node2D
var rate_of_fire = 0.8
var current_ammo = MAX_AMMO
var can_shoot = true
var is_alive = true

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
	health -= randi_range(10, 15)
	health_bar.value = health
	get_tree().create_timer(0.5).timeout.connect(_update_damage_bar)
	if health <= 0:
		is_alive = false
		animated_sprite_2d.play("dead")
		collision_shape_2d.queue_free()
		health_bar.visible = false
		damage_bar.visible = false
		await get_tree().create_timer(10.0).timeout
		queue_free()
	else:
		see_player()

func see_player():
	player = find_player_node(get_tree().get_root())
	if player != null:
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
	while damage_bar.value > health_bar.value:
		damage_bar.value -= 1
		await get_tree().create_timer(0.05).timeout

func _on_area_2d_body_entered(body):
	if body.name == "Player" and is_alive:
		animated_sprite_2d.play("weapon")
		player = body

func _process(_delta):
	if player != null and is_alive:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= DETECTION_RANGE:
			animated_sprite_2d.look_at(player.global_position)
			if can_shoot:
				shoot()
		else:
			follow_player()
	else:
		player = null

func follow_player():
	if player != null and is_alive:
		navigation_agent.set_target_position(player.global_position)
		if navigation_agent.is_target_reached():
			velocity = Vector2.ZERO
		else:
			velocity = navigation_agent.get_next_path_position() - global_position
			velocity = velocity.normalized() * SPEED
		move_and_slide()
		animated_sprite_2d.look_at(player.global_position)

func shoot():
	if current_ammo == 0:
		reload()
		return
	
	if player.is_alive:
		can_shoot = false
		current_ammo -= 1
		var miss = randf() < MISS_CHANGE
		var angle_offset = 0.0
		if miss:
			angle_offset = deg_to_rad(randf_range(-MAX_MISS_CHANGE, MAX_MISS_CHANGE))
		var bullet = bullet_scene.instantiate() as Area2D
		var marker_position = $AnimatedSprite2D/Marker2D.global_position
		bullet.position = marker_position
		bullet.rotation = (player.global_position - marker_position).angle() + angle_offset
		get_parent().add_child(bullet)
		await get_tree().create_timer(rate_of_fire).timeout
		can_shoot = true

func reload():
	can_shoot = false
	await get_tree().create_timer(1.5).timeout
	current_ammo = MAX_AMMO
	can_shoot = true
