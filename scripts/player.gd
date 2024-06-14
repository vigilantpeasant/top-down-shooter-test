extends CharacterBody2D

@onready var reload_bar = $"/root/Main/LevelStructure/GUI/HUD/AmmoPanel/Ammo/ReloadBar"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var marker_2d = $AnimatedSprite2D/Marker2D
@onready var material_label = $"/root/Main/LevelStructure/GUI/HUD/MaterialPanel/MaterialLabel"
@onready var ammo = $"/root/Main/LevelStructure/GUI/HUD/AmmoPanel/Ammo"
@onready var health_bar = $"/root/Main/LevelStructure/GUI/HUD/HealthBar" as TextureProgressBar
@onready var health_label = $"/root/Main/LevelStructure/GUI/HUD/HealthBar/HealthLabel" as Label
@onready var damage_bar = $"/root/Main/LevelStructure/GUI/HUD/HealthBar/DamageBar" as ProgressBar
@onready var game_over = $"/root/Main/LevelStructure/GUI/GameOver"
@onready var game_ui = $/root/Main/LevelStructure/GUI/HUD
@onready var dash_effect = $"/root/Main/LevelStructure/GUI/HUD/DashPanel/DashEffect"
@onready var grenade_bar = $"/root/Main/LevelStructure/GUI/HUD/GrenadePanel/GrenadeBar"
@onready var GUI_animation = $"/root/Main/LevelStructure/AnimationPlayer"

const SPEED = 200
const DASH_SPEED = 600
const DASH_DURATION = 0.2
const DASH_INTERVAL = 0.5
const RATE_OF_FIRE = 0.2
const GRENADE_INTERVAL = 2.0
const MISS_CHANCE = 0.3
const MAX_MISS_ANGLE = 5.0
const MAX_AMMO = 20
const RELOAD_TIME = 1.2

var direction : Vector2
var health = 100
var max_health = 100
var dash_timer = 0.0
var dashing = false
var can_dash = true
var current_ammo = MAX_AMMO
var can_shoot = true
var is_reloading = false
var can_throw_grenade = true
var is_alive = true
var is_moving = false

func _ready():
	animated_sprite_2d.play("idle")
	ammo.text = str(current_ammo)
	health_label.text = str(health) + " / " + str(max_health)
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	if damage_bar:
		damage_bar.max_value = max_health
		damage_bar.value = health
	if dash_effect:
		dash_effect.max_value = 100
		dash_effect.value = 0
	reload_bar.visible = false
	update_health_bar_texture()

func _physics_process(_delta):
	if not is_alive:
		return
	
	look_at(get_global_mouse_position())
	direction = Input.get_vector("left", "right", "up", "down")
	is_moving = direction.length() > 0

	if dashing:
		velocity = direction * DASH_SPEED
		dash_timer -= _delta
		if dash_timer <= 0:
			dashing = false
	else:
		velocity = direction * SPEED
	move_and_slide()

func _process(_delta):
	if not is_alive:
		return
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		animated_sprite_2d.play("gun")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
			shoot()
	else:
		animated_sprite_2d.play("idle")
	
	if Input.is_action_just_pressed("grenade") and can_throw_grenade:
		throw_grenade()
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		dash_timer = DASH_DURATION
		dash_effect.value = 0
		can_dash = false
		increment_dash_effect()

	if Input.is_action_just_pressed("reload") and not is_reloading and current_ammo < MAX_AMMO:
		is_reloading = true
		can_shoot = false
		reload_bar.visible = true
		reload_bar.value = 0
		ammo.text = "Re"
		increment_reload_bar()
	
	if is_reloading:
		animated_sprite_2d.play("gun")

func increment_dash_effect():
	var step = 0.05
	var increment_amount = 100.0 * step / DASH_INTERVAL
	dash_effect.value += increment_amount
	if dash_effect.value < 100:
		var timer = create_timer(step)
		timer.timeout.connect(increment_dash_effect)
	else:
		dash_effect.value = 0
		can_dash = true

func increment_grenade_bar():
	var step = 0.05
	var increment_amount = 100.0 * step / GRENADE_INTERVAL
	grenade_bar.value += increment_amount
	if grenade_bar.value < 100:
		var timer = create_timer(step)
		timer.timeout.connect(increment_grenade_bar)
	else:
		grenade_bar.value = 0
		can_throw_grenade = true

func throw_grenade():
	if not is_alive:
		return
	can_throw_grenade = false
	var new_grenade = preload("res://assets/grenade.tscn").instantiate()
	new_grenade.global_position = marker_2d.global_position
	new_grenade.global_rotation = marker_2d.global_rotation
	marker_2d.add_child(new_grenade)
	grenade_bar.value = 0
	increment_grenade_bar()
	await create_timer(2.0).timeout

func shoot():
	if current_ammo <= 0 or is_reloading or not is_alive:
		return
	can_shoot = false
	current_ammo -= 1
	ammo.text = str(current_ammo)
	
	var miss_chance = MISS_CHANCE
	if is_moving:
		miss_chance = MISS_CHANCE
	else:
		miss_chance = 0.0

	var angle_offset = 0.0
	if randf() < miss_chance:
		angle_offset = deg_to_rad(randf_range(-MAX_MISS_ANGLE, MAX_MISS_ANGLE))
	var new_bullet = preload("res://assets/bullet.tscn").instantiate()
	new_bullet.modulate = Color("ORCHID")
	new_bullet.global_position = marker_2d.global_position
	new_bullet.global_rotation = marker_2d.global_rotation + angle_offset
	marker_2d.add_child(new_bullet)
	
	await create_timer(RATE_OF_FIRE).timeout
	can_shoot = true

func increment_reload_bar():
	var step = 0.05
	var increment_amount = 100.0 * step / RELOAD_TIME
	reload_bar.value += increment_amount
	if reload_bar.value < 100:
		var timer = create_timer(step)
		timer.timeout.connect(increment_reload_bar)
	else:
		current_ammo = MAX_AMMO
		ammo.text = str(current_ammo)
		reload_bar.visible = false
		is_reloading = false
		await create_timer(0.5).timeout
		can_shoot = true

func take_damage(min_damage : int, max_damage : int):
	if not can_dash or not is_alive:
		return
	
	var blood = preload("res://assets/particle.tscn").instantiate() as GPUParticles2D
	blood.modulate = Color(0.117647, 0.564706, 1, 1)
	get_parent().add_child(blood)
	blood.global_position = global_position + direction * 10
	blood.global_rotation = direction.angle()
	blood.emitting = true
	
	health -= randi_range(min_damage, max_damage)
	if health_bar:
		health_bar.value = health
		health_label.text = str(health) + " / " + str(max_health)
	create_timer(0.5).timeout.connect(_update_damage_bar)
	update_health_bar_texture()
	
	if health <= 0:
		if health_bar:
			health_bar.value = 0
		if damage_bar:
			damage_bar.value = 0
		is_alive = false
		animated_sprite_2d.play("dead")
		game_over.visible = true
		GUI_animation.play("game_over")
		game_ui.visible = false

func _update_damage_bar():
	if damage_bar and damage_bar.value > health_bar.value:
		damage_bar.value -= 1
		health_label.text = str(health) + " / " + str(max_health)
		if damage_bar.value > health_bar.value:
			create_timer(0.05).timeout.connect(_update_damage_bar)

func update_health_bar_texture():
	if health > 75:
		health_bar.texture_progress = preload("res://assets/progress.png")
	elif health > 50:
		health_bar.texture_progress = preload("res://assets/progress2.png")
	elif health > 25:
		health_bar.texture_progress = preload("res://assets/progress3.png")
	else:
		health_bar.texture_progress = preload("res://assets/progress4.png")

func create_timer(wait_time: float) -> Timer:
	var timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	add_child(timer)
	timer.start()
	return timer
