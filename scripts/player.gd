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
@onready var dash_effect = LevelStructure.get_node("GUI/HUD/DashPanel/DashEffect")
@onready var grenade_bar = LevelStructure.get_node("GUI/HUD/GrenadePanel/GrenadeBar")
@onready var melee_bar = LevelStructure.get_node("GUI/HUD/MeleePanel/MeleeBar")
var blood_scene = preload("res://assets/particle.tscn")
var grenade_scene = preload("res://assets/grenade.tscn")
var bullet_scene = preload("res://assets/bullet.tscn")
var audio_player = preload("res://assets/audio.tscn")

const SPEED = 250
const DASH_SPEED = 650
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
var max_total_rifle_ammo = 20
var max_total_pistol_ammo = 10
var total_rifle_ammo = max_total_rifle_ammo
var total_pistol_ammo = max_total_pistol_ammo
var is_alive = true
var is_moving = false

func _ready():
	LevelStructure.on_start()
	animated_sprite_2d.play("idle")
	health_label.text = str(health) + " / " + str(max_health)
	health_bar.max_value = max_health
	health_bar.value = health
	damage_bar.max_value = max_health
	damage_bar.value = health
	dash_effect.max_value = 100
	dash_effect.value = 0
	reload_bar.visible = false
	
	update_ammo_text()
	reset_effects()
	update_health_bar_texture()

func _physics_process(delta):
	if not is_alive:
		return
	
	look_at(get_global_mouse_position())
	direction = Input.get_vector("left", "right", "up", "down")
	is_moving = direction.length() > 0
	if dashing:
		velocity = direction * DASH_SPEED
		dash_timer -= delta
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
		Audio.play_sound("dash")
		dash_timer = DASH_DURATION
		dash_effect.value = 0
		can_dash = false
		increment_dash_effect()

	if Input.is_action_just_pressed("reload") and not is_reloading:
		if (GameState.selected_weapon == "plasma rifle" and current_rifle_ammo < MAX_RIFLE_AMMO and total_rifle_ammo > 0) or (GameState.selected_weapon == "plasma pistol" and current_pistol_ammo < MAX_PISTOL_AMMO and total_pistol_ammo > 0):
			is_reloading = true
			can_shoot = false
			Audio.play_sound("plasma_reload")
			reload_bar.visible = true
			reload_bar.value = 0
			ammo.text = "Reload"
			increment_reload_bar()
	
	if Settings.autoreload and not is_reloading:
		if (GameState.selected_weapon == "plasma rifle" and current_rifle_ammo == 0 and total_rifle_ammo > 0) or (GameState.selected_weapon == "plasma pistol" and current_pistol_ammo == 0 and total_pistol_ammo > 0):
			is_reloading = true
			can_shoot = false
			Audio.play_sound("plasma_reload")
			reload_bar.visible = true
			reload_bar.value = 0
			ammo.text = "Reload"
			increment_reload_bar()
	
	if is_reloading:
		animated_sprite_2d.play("gun")
		if GameState.selected_weapon == "plasma rifle":
			animated_sprite_2d.frame = 0
		elif GameState.selected_weapon == "plasma pistol":
			animated_sprite_2d.frame = 1

func reset_effects():
	melee_bar.value = 0
	dash_effect.value = 0
	grenade_bar.value = 0

func _on_melee_attack_body_entered(body):
	if body.is_in_group("Wood"):
		Audio.play_sound("box_break")
	elif body.is_in_group("Metal"):
		Audio.play_sound("metal_break")
	
	if body.has_method("take_damage"):
		body.take_damage(7, 20, global_position)

func melee_attack():
	if not is_alive:
		return
	
	can_melee = false
	$MeleeAttack/CollisionShape2D.disabled = false
	$MeleeAttack/Slash.visible = true
	animated_sprite_2d.play("melee")
	Audio.play_sound("slash")
	await get_tree().create_timer(0.1).timeout
	$MeleeAttack/CollisionShape2D.disabled = true
	$MeleeAttack/Slash.visible = false
	animated_sprite_2d.play("idle")
	
	melee_bar.value = 0
	increment_melee_effect()
	await get_tree().create_timer(MELEE_INTERVAL).timeout

func update_ammo_text():
	if GameState.selected_weapon == "plasma rifle":
		ammo.text = str(current_rifle_ammo) + " / " + str(total_rifle_ammo)
	elif GameState.selected_weapon == "plasma pistol":
		ammo.text = str(current_pistol_ammo) + " / " + str(total_pistol_ammo)

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
	var new_grenade = grenade_scene.instantiate()
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
		update_ammo_text()
	elif GameState.selected_weapon == "plasma pistol":
		current_pistol_ammo -= 1
		update_ammo_text()
	
	var miss_chance = MISS_CHANCE
	if is_moving:
		miss_chance = MISS_CHANCE
	else:
		miss_chance = 0.0

	var angle_offset = 0.0
	if randf() < miss_chance:
		angle_offset = deg_to_rad(randf_range(-MAX_MISS_ANGLE, MAX_MISS_ANGLE))
	var new_bullet = bullet_scene.instantiate()
	new_bullet.modulate = Color(0.94581073522568, 0.00072908459697, 0.94580382108688)
	new_bullet.global_position = marker_2d.global_position
	new_bullet.global_rotation = marker_2d.global_rotation + angle_offset
	marker_2d.add_child(new_bullet)
	
	var rate_of_fire
	if GameState.selected_weapon == "plasma rifle":
		rate_of_fire = RATE_OF_FIRE_RIFLE
		Audio.play_sound("plasma_rifle_shoot")
	elif GameState.selected_weapon == "plasma pistol":
		rate_of_fire = RATE_OF_FIRE_PISTOL
		Audio.play_sound("plasma_pistol_shoot")
	
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
			var ammo_needed = MAX_RIFLE_AMMO - current_rifle_ammo
			var ammo_to_reload = min(ammo_needed, total_rifle_ammo)
			current_rifle_ammo += ammo_to_reload
			total_rifle_ammo -= ammo_to_reload
		elif GameState.selected_weapon == "plasma pistol":
			var ammo_needed = MAX_PISTOL_AMMO - current_pistol_ammo
			var ammo_to_reload = min(ammo_needed, total_pistol_ammo)
			current_pistol_ammo += ammo_to_reload
			total_pistol_ammo -= ammo_to_reload
		update_ammo_text()
		
		reload_bar.visible = false
		await get_tree().create_timer(0.5).timeout
		is_reloading = false
		can_shoot = true

func take_damage(min_damage : int, max_damage : int, hit_position : Vector2):
	if not can_dash or not is_alive:
		return
	
	var blood = blood_scene.instantiate() as GPUParticles2D
	blood.modulate = Color(0.117647, 0.564706, 1, 1)
	get_parent().add_child(blood)
	var particle_direction = (global_position - hit_position).normalized()
	blood.global_position = hit_position + particle_direction * 10
	blood.global_rotation = particle_direction.angle()
	blood.emitting = true
	
	health -= randi_range(min_damage, max_damage)
	if health_bar:
		health_bar.value = health
		health_label.text = str(health) + " / " + str(max_health)
	get_tree().create_timer(0.5).timeout.connect(update_damage_bar)
	update_health_bar_texture()
	
	if health <= 0:
		if health_bar:
			health_bar.value = 0
		if damage_bar:
			damage_bar.value = 0
		is_alive = false
		animated_sprite_2d.play("dead")
		LevelStructure.on_death()
	
	await get_tree().create_timer(0.4).timeout
	blood.queue_free()

func update_damage_bar():
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
