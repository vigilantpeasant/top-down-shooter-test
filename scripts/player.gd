extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var marker_2d = $AnimatedSprite2D/Marker2D
@onready var reload_bar = LevelStructure.get_node("GUI/HUD/AmmoPanel/Ammo/ReloadBar")
@onready var weapon_bar = LevelStructure.get_node("GUI/HUD/Weapons/WeaponBar") as ProgressBar
@onready var material_label = LevelStructure.get_node("GUI/HUD/MaterialPanel/MaterialLabel")
@onready var ammo = LevelStructure.get_node("GUI/HUD/AmmoPanel/Ammo")
@onready var health_bar = LevelStructure.get_node("GUI/HUD/HealthBar") as TextureProgressBar
@onready var health_label = LevelStructure.get_node("GUI/HUD/HealthBar/HealthLabel") as Label
@onready var damage_bar = LevelStructure.get_node("GUI/HUD/HealthBar/DamageBar") as ProgressBar
@onready var game_over = LevelStructure.get_node("GUI/GameOver")
@onready var game_ui = LevelStructure.get_node("GUI/HUD")
@onready var dash_effect = LevelStructure.get_node("GUI/HUD/DashPanel/DashEffect")
@onready var grenade_bar = LevelStructure.get_node("GUI/HUD/GrenadePanel/GrenadeBar")
@onready var melee_bar = LevelStructure.get_node("GUI/HUD/MeleePanel/MeleeBar")
@onready var GUI_animation = LevelStructure.get_node("AnimationPlayer")
@onready var gui = LevelStructure.get_node("GUI")

const SPEED = 200
const DASH_SPEED = 600
const DASH_DURATION = 0.2
const DASH_INTERVAL = 0.5
const RATE_OF_FIRE_RIFLE = 0.2
const RATE_OF_FIRE_PISTOL = 0.3
const GRENADE_INTERVAL = 2.0
const MELEE_INTERVAL = 0.3
const MISS_CHANCE = 0.3
const MAX_MISS_ANGLE = 5.0
const MAX_RIFLE_AMMO = 20
const MAX_PISTOL_AMMO = 10
const RELOAD_TIME = 1.2

var direction : Vector2
var health = 100
var max_health = 100
var dash_timer = 0.0
var dashing = false
var can_dash = true
var current_rifle_ammo = MAX_RIFLE_AMMO
var current_pistol_ammo = MAX_PISTOL_AMMO
var can_shoot = true
var can_melee = true
var is_reloading = false
var can_throw_grenade = true
var is_alive = true
var is_moving = false

func _ready():
	gui.visible = true
	game_over.visible = false
	game_ui.visible = true
	animated_sprite_2d.play("idle")
	health_label.text = str(health) + " / " + str(max_health)
	update_ammo_text()
	
	health_bar.max_value = max_health
	health_bar.value = health
	damage_bar.max_value = max_health
	damage_bar.value = health
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
	
	if Input.is_action_just_pressed("key1") and not is_reloading:
		GameState.selected_weapon = "plasma rifle"
		weapon_bar.position = Vector2(0, 0)
		update_ammo_text()
	if Input.is_action_just_pressed("key2") and not is_reloading:
		GameState.selected_weapon = "plasma pistol"
		weapon_bar.position = Vector2(65, 0)
		update_ammo_text()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		animated_sprite_2d.play("gun")
		if GameState.selected_weapon == "plasma rifle":
			animated_sprite_2d.frame = 0
		elif GameState.selected_weapon == "plasma pistol":
			animated_sprite_2d.frame = 1
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_shoot:
			shoot()
	else:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_melee and not is_reloading:
			melee_attack()
		else:
			animated_sprite_2d.play("idle")
	
	if Input.is_action_just_pressed("grenade") and can_throw_grenade:
		throw_grenade()
	
	if Input.is_action_just_pressed("dash") and can_dash and is_moving:
		dashing = true
		dash_timer = DASH_DURATION
		dash_effect.value = 0
		can_dash = false
		increment_dash_effect()

	if Input.is_action_just_pressed("reload") and not is_reloading:
		if (GameState.selected_weapon == "plasma rifle" and current_rifle_ammo < MAX_RIFLE_AMMO) or (GameState.selected_weapon == "plasma pistol" and current_pistol_ammo < MAX_PISTOL_AMMO):
			is_reloading = true
			can_shoot = false
			reload_bar.visible = true
			reload_bar.value = 0
			ammo.text = "Re"
			increment_reload_bar()
	
	if is_reloading:
		animated_sprite_2d.play("gun")
		if GameState.selected_weapon == "plasma rifle":
			animated_sprite_2d.frame = 0
		elif GameState.selected_weapon == "plasma pistol":
			animated_sprite_2d.frame = 1

func _on_melee_attack_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(7, 20)

func melee_attack():
	if not is_alive:
		return
	can_melee = false
	
	$MeleeAttack/CollisionShape2D.disabled = false
	$MeleeAttack/Slash.visible = true
	animated_sprite_2d.play("melee")
	await get_tree().create_timer(0.1).timeout
	$MeleeAttack/CollisionShape2D.disabled = true
	$MeleeAttack/Slash.visible = false
	animated_sprite_2d.play("idle")
	
	melee_bar.value = 0
	increment_melee_effect()
	await get_tree().create_timer(MELEE_INTERVAL).timeout

func update_ammo_text():
	if GameState.selected_weapon == "plasma rifle":
		ammo.text = str(current_rifle_ammo)
	elif GameState.selected_weapon == "plasma pistol":
		ammo.text = str(current_pistol_ammo)

func increment_melee_effect():
	var step = 0.05
	var increment_amount = 100.0 * step / MELEE_INTERVAL
	melee_bar.value += increment_amount
	if melee_bar.value < 100:
		get_tree().create_timer(step).timeout.connect(increment_melee_effect)
	else:
		melee_bar.value = 0
		can_melee = true

func increment_dash_effect():
	var step = 0.05
	var increment_amount = 100.0 * step / DASH_INTERVAL
	dash_effect.value += increment_amount
	if dash_effect.value < 100:
		get_tree().create_timer(step).timeout.connect(increment_dash_effect)
	else:
		dash_effect.value = 0
		can_dash = true

func increment_grenade_bar():
	var step = 0.05
	var increment_amount = 100.0 * step / GRENADE_INTERVAL
	grenade_bar.value += increment_amount
	if grenade_bar.value < 100:
		get_tree().create_timer(step).timeout.connect(increment_grenade_bar)
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
	await get_tree().create_timer(GRENADE_INTERVAL).timeout

func shoot():
	if (GameState.selected_weapon == "plasma rifle" and current_rifle_ammo <= 0) or (GameState.selected_weapon == "plasma pistol" and current_pistol_ammo <= 0) or is_reloading or not is_alive:
		return
	
	can_shoot = false
	if GameState.selected_weapon == "plasma rifle":
		current_rifle_ammo -= 1
		ammo.text = str(current_rifle_ammo)
	elif GameState.selected_weapon == "plasma pistol":
		current_pistol_ammo -= 1
		ammo.text = str(current_pistol_ammo)
	
	var miss_chance = MISS_CHANCE
	if is_moving:
		miss_chance = MISS_CHANCE
	else:
		miss_chance = 0.0

	var angle_offset = 0.0
	if randf() < miss_chance:
		angle_offset = deg_to_rad(randf_range(-MAX_MISS_ANGLE, MAX_MISS_ANGLE))
	var new_bullet = preload("res://assets/bullet.tscn").instantiate()
	new_bullet.modulate = Color(0.94581073522568, 0.00072908459697, 0.94580382108688)
	new_bullet.global_position = marker_2d.global_position
	new_bullet.global_rotation = marker_2d.global_rotation + angle_offset
	marker_2d.add_child(new_bullet)
	
	var rate_of_fire
	if GameState.selected_weapon == "plasma rifle":
		rate_of_fire = RATE_OF_FIRE_RIFLE
	elif GameState.selected_weapon == "plasma pistol":
		rate_of_fire = RATE_OF_FIRE_PISTOL
	
	await get_tree().create_timer(rate_of_fire).timeout
	can_shoot = true

func increment_reload_bar():
	var step = 0.05
	var increment_amount = 100.0 * step / RELOAD_TIME
	reload_bar.value += increment_amount
	if reload_bar.value < 100:
		get_tree().create_timer(step).timeout.connect(increment_reload_bar)
	else:
		if GameState.selected_weapon == "plasma rifle":
			current_rifle_ammo = MAX_RIFLE_AMMO
		elif GameState.selected_weapon == "plasma pistol":
			current_pistol_ammo = MAX_PISTOL_AMMO
		update_ammo_text()
		
		reload_bar.visible = false
		is_reloading = false
		await get_tree().create_timer(0.5).timeout
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
	get_tree().create_timer(0.5).timeout.connect(_update_damage_bar)
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
	
	await get_tree().create_timer(0.4).timeout
	blood.queue_free()

func _update_damage_bar():
	while damage_bar.value > health_bar.value:
		damage_bar.value -= 1
		health_label.text = str(health) + " / " + str(max_health)
		await get_tree().create_timer(0.05).timeout

func update_health_bar_texture():
	if health > 75:
		health_bar.texture_progress = preload("res://assets/progress.png")
	elif health > 50:
		health_bar.texture_progress = preload("res://assets/progress2.png")
	elif health > 25:
		health_bar.texture_progress = preload("res://assets/progress3.png")
	else:
		health_bar.texture_progress = preload("res://assets/progress4.png")
