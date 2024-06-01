extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var health_bar = $"../GUI/HealthBar"
@onready var damage_bar = $"../GUI/HealthBar/DamageBar"
@onready var marker_2d = %Marker2D
@onready var label = $"../GUI/Label"

const SPEED = 200
const DASH_SPEED = 600
const DASH_DURATION = 0.2
const DASH_INTERVAL = 0.5
const RATE_OF_FIRE = 0.2
const MISS_CHANCE = 0.3
const MAX_MISS_ANGLE = 10.0
const MAX_AMMO = 15
const RELOAD_TIME = 2.0

var can_shoot = true
var HEALTH = 100
var MAX_HEALTH = 100
var dashing = false
var dash_timer = 0.0
var can_dash = true
var CURRENT_AMMO = MAX_AMMO
var is_reloading = false

func _ready():
	label.text = str(CURRENT_AMMO)
	health_bar.max_value = MAX_HEALTH
	health_bar.value = HEALTH
	damage_bar.max_value = MAX_HEALTH
	damage_bar.value = HEALTH

func _update_damage_bar():
	if damage_bar.value > health_bar.value:
		damage_bar.value -= 1
		if damage_bar.value > health_bar.value:
			create_timer(0.05).timeout.connect(_update_damage_bar)

func _physics_process(_delta):
	look_at(get_global_mouse_position())
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if dashing:
		velocity = direction * DASH_SPEED
		dash_timer -= _delta
		if dash_timer <= 0:
			dashing = false
	else:
		velocity = direction * SPEED
	
	move_and_slide()

func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		animated_sprite_2d.play("gun")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
			shoot()
	else:
		animated_sprite_2d.play("idle")
	
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

	if Input.is_action_just_pressed("reload") and not is_reloading:
		reload()
	
	if is_reloading == true:
		animated_sprite_2d.play("gun")

func start_dash():
	dashing = true
	dash_timer = DASH_DURATION
	can_dash = false
	create_timer(DASH_INTERVAL).timeout.connect(reset_dash)

func reset_dash():
	can_dash = true

func shoot():
	if CURRENT_AMMO <= 0 or is_reloading:
		return
	can_shoot = false
	CURRENT_AMMO -= 1
	label.text = str(CURRENT_AMMO)
	var miss = randf() < MISS_CHANCE
	var angle_offset = 0.0
	if miss:
		angle_offset = deg_to_rad(randf_range(-MAX_MISS_ANGLE, MAX_MISS_ANGLE))
	
	const BULLET = preload("res://scenes/bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = marker_2d.global_position
	new_bullet.global_rotation = marker_2d.global_rotation + angle_offset
	marker_2d.add_child(new_bullet)
	
	await create_timer(RATE_OF_FIRE).timeout
	can_shoot = true

func take_damage():
	if can_dash == false:
		pass
	else:
		HEALTH -= 10
		health_bar.value = HEALTH
		create_timer(0.5).timeout.connect(_update_damage_bar)
		if HEALTH <= 0:
			queue_free()

func reload():
	is_reloading = true
	label.text = "reloading"
	await create_timer(RELOAD_TIME).timeout
	CURRENT_AMMO = MAX_AMMO
	label.text = str(CURRENT_AMMO)
	is_reloading = false

func create_timer(wait_time: float) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	add_child(timer)
	timer.start()
	return timer
