extends CharacterBody2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var health_bar = $"../GUI/HealthBar"
@onready var damage_bar = $"../GUI/HealthBar/DamageBar"

const speed = 200 #player speed is 200
var rate_of_fire = 0.2 #seconds per bullet
var can_shoot = true
var health = 100
var max_health = 100
var shoot_interval: float = 1.0
var miss_chance: float = 0.3
var max_miss_angle: float = 15.0

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	damage_bar.max_value = max_health
	damage_bar.value = health

func _update_damage_bar():
	if damage_bar.value > health_bar.value:
		damage_bar.value -= 1
		if damage_bar.value > health_bar.value:
			get_tree().create_timer(0.05).timeout.connect(_update_damage_bar)

func _physics_process(_delta):
	look_at(get_global_mouse_position()) #player can look around with mouse
	var direction = Input.get_vector("left","right","up","down") #set direction
	velocity = direction * speed #set velocity
	move_and_slide() #move

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		animated_sprite_2d.play("shotgun") 
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot == true:
			shoot()
	else:
		animated_sprite_2d.play("idle")

func shoot():
	can_shoot = false
	var miss = randf() < miss_chance
	var angle_offset = 0.0
	if miss:
		angle_offset = deg_to_rad(randf_range(-max_miss_angle, max_miss_angle))
	const BULLET = preload("res://scenes/bullet.tscn")
	var newBullet = BULLET.instantiate()
	newBullet.global_position = %Marker2D.global_position 
	newBullet.global_rotation = %Marker2D.global_rotation + angle_offset
	%Marker2D.add_child(newBullet)
	await(get_tree().create_timer(rate_of_fire)).timeout
	can_shoot = true

func take_damage():
	health -= 10
	health_bar.value = health
	get_tree().create_timer(0.5).timeout.connect(_update_damage_bar)
	if health <= 0:
		queue_free()
