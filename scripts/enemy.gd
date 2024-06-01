extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@export var bullet_scene: PackedScene
@onready var health_bar = $Healthbar
@onready var damage_bar = $Healthbar/DamageBar
@onready var navigation_agent = $NavigationAgent2D

const SPEED = 120
const MISS_CHANGE = 0.6
const MAX_MISS_CHANGE = 15.0
const DETECTION_RANGE = 350.0

var HEALTH = 50
var MAX_HEALTH = 50
var PLAYER: Node2D
var RATE_OF_FIRE = 0.8
var can_shoot = true

func _ready():
	health_bar.max_value = MAX_HEALTH
	health_bar.value = HEALTH
	damage_bar.max_value = MAX_HEALTH
	damage_bar.value = HEALTH
	
	if HEALTH == MAX_HEALTH:
		health_bar.visible = false
		damage_bar.visible = false

func take_damage():
	health_bar.visible = true
	damage_bar.visible = true
	HEALTH -= 15
	health_bar.value = HEALTH
	get_tree().create_timer(0.5).timeout.connect(_update_damage_bar)
	if HEALTH <= 0:
		queue_free()
	else:
		see_player()

func see_player():
	var player_node = find_player_node(get_tree().get_root())
	if player_node != null:
		PLAYER = player_node
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
		PLAYER = body

func _process(_delta):
	if PLAYER != null:
		var distance_to_player = global_position.distance_to(PLAYER.global_position)
		if distance_to_player <= DETECTION_RANGE:
			animated_sprite_2d.look_at(PLAYER.global_position)
			if can_shoot:
				shoot()
		else:
			follow_player()
	else:
		PLAYER = null

func follow_player():
	if PLAYER != null:
		navigation_agent.set_target_position(PLAYER.global_position)
		if navigation_agent.is_target_reached():
			velocity = Vector2.ZERO
		else:
			velocity = navigation_agent.get_next_path_position() - global_position
			velocity = velocity.normalized() * SPEED
		move_and_slide()
		animated_sprite_2d.look_at(PLAYER.global_position)

func shoot():
	can_shoot = false
	var miss = randf() < MISS_CHANGE
	var angle_offset = 0.0
	if miss:
		angle_offset = deg_to_rad(randf_range(-MAX_MISS_CHANGE, MAX_MISS_CHANGE))
	var bullet = bullet_scene.instantiate() as Area2D
	var marker_position = $AnimatedSprite2D/Marker2D.global_position
	bullet.position = marker_position
	bullet.rotation = (PLAYER.global_position - marker_position).angle() + angle_offset
	get_parent().add_child(bullet)
	await get_tree().create_timer(RATE_OF_FIRE).timeout
	can_shoot = true
