extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var health_bar = $"../GUI/HealthBar"
@onready var damage_bar = $"../GUI/HealthBar/DamageBar"
@onready var marker_2d = %Marker2D

const speed = 200
const dash_speed = 600
const dash_duration : float  = 0.2
const dash_interval : float = 0.5
var rate_of_fire: float = 0.2
var can_shoot = true
var health = 100
var max_health = 100
var miss_chance: float = 0.3
var max_miss_angle: float = 10.0
var dashing = false
var dash_timer = 0.0
var can_dash = true

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	damage_bar.max_value = max_health
	damage_bar.value = health

func _update_damage_bar():
	if damage_bar.value > health_bar.value:
		damage_bar.value -= 1
		if damage_bar.value > health_bar.value:
			create_timer(0.05).timeout.connect(_update_damage_bar)

func _physics_process(_delta):
	look_at(get_global_mouse_position())
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if dashing:
		velocity = direction * dash_speed
		dash_timer -= _delta
		if dash_timer <= 0:
			dashing = false
	else:
		velocity = direction * speed
	
	move_and_slide()

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		animated_sprite_2d.play("shotgun")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
			shoot()
	else:
		animated_sprite_2d.play("idle")
	
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

func start_dash():
	dashing = true
	dash_timer = dash_duration
	can_dash = false
	create_timer(dash_interval).timeout.connect(reset_dash)

func reset_dash():
	can_dash = true

func shoot():
	can_shoot = false
	var miss = randf() < miss_chance
	var angle_offset = 0.0
	if miss:
		angle_offset = deg_to_rad(randf_range(-max_miss_angle, max_miss_angle))
	
	const BULLET = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = marker_2d.global_position
	new_bullet.global_rotation = marker_2d.global_rotation + angle_offset
	marker_2d.add_child(new_bullet)
	
	await create_timer(rate_of_fire).timeout
	can_shoot = true

func take_damage():
	health -= 10
	health_bar.value = health
	create_timer(0.5).timeout.connect(_update_damage_bar)
	if health <= 0:
		queue_free()

func create_timer(wait_time: float) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	add_child(timer)
	timer.start()
	return timer
