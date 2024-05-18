extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@export var bullet_scene: PackedScene
@onready var health_bar = $Healthbar
@onready var damage_bar = $Healthbar/DamageBar

var health = 50
var max_health = 50
var speed = 100
var player: Node2D
var can_shoot = true
var shoot_interval: float = 1.0
var miss_chance: float = 0.6
var max_miss_angle: float = 15.0

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	damage_bar.max_value = max_health
	damage_bar.value = health

func take_damage():
	health -= 15
	health_bar.value = health
	get_tree().create_timer(0.5).timeout.connect(_update_damage_bar)
	if health <= 0:
		queue_free()

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
		animated_sprite_2d.look_at(player.global_position)
		if can_shoot:
			shoot()
	else:
		player = null

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
	await get_tree().create_timer(shoot_interval).timeout
	can_shoot = true

