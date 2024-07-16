extends CharacterBody2D
class_name Enemy

@export var bullet_scene: PackedScene
@onready var health_bar = $HealthBar
@onready var damage_bar = $HealthBar/DamageBar
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var navigation_agent = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var ray_cast_2d = $RayCast2D

@export var speed = 120
@export var miss_chance = 0.5
@export var max_miss_chance = 10.0
@export var max_ammo = 15
@export var rate_of_fire = 0.8
@export var max_health = 50
@export var detection_range = 200.0

@onready var health = max_health
var random_skin: int
var player: Node2D
var current_ammo = max_ammo
var can_shoot = true
var is_alive = true
var hit_scene = preload("res://assets/blood_splash.tscn")
var death_blood = preload("res://assets/blood_particle.tscn")

func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	damage_bar.max_value = max_health
	damage_bar.value = health
	random_skin = randi_range(0, 3)
	animated_sprite_2d.frame = random_skin
	
	if health == max_health:
		health_bar.visible = false
		damage_bar.visible = false

func take_damage(min_damage: int, max_damage: int, hit_position : Vector2):
	health_bar.visible = true
	damage_bar.visible = true
	Audio.play_sound("bullet_hit")
	
	var blood = hit_scene.instantiate() as GPUParticles2D
	blood.modulate = Color(0.698039, 0.133333, 0.133333, 1)
	get_parent().add_child(blood)
	var direction = (global_position - hit_position).normalized()
	blood.global_position = hit_position + direction * 10
	blood.global_rotation = direction.angle()
	blood.emitting = true
	
	health -= randi_range(min_damage, max_damage)
	health_bar.value = health
	get_tree().create_timer(0.5).timeout.connect(update_damage_bar)
	if health <= 0:
		var death_blood_particle = death_blood.instantiate() as GPUParticles2D
		get_parent().add_child(death_blood_particle)
		death_blood_particle.global_position = global_position
		death_blood_particle.emitting = true
		
		is_alive = false
		animated_sprite_2d.play("dead")
		z_index = 0
		animated_sprite_2d.frame = random_skin
		collision_shape_2d.queue_free()
		health_bar.visible = false
		damage_bar.visible = false
		create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 10.0)
		await get_tree().create_timer(10.0).timeout
		queue_free()
	else:
		alert_nearby_enemies()
		see_player()
	
	await get_tree().create_timer(10).timeout
	blood.queue_free()

func alert_nearby_enemies():
	var enemies_in_range = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies_in_range:
		if enemy!= self and enemy.is_alive and global_position.distance_to(enemy.global_position) <= detection_range:
			enemy.see_player()

func see_player():
	player = find_player_node(get_tree().get_root())
	if player != null:
		animated_sprite_2d.play("weapon")
		animated_sprite_2d.frame = random_skin

func find_player_node(node):
	if node.has_node("Player"):
		return node.get_node("Player")
	
	for child in node.get_children():
		var result = find_player_node(child)
		if result != null:
			return result
	
	return null

func update_damage_bar():
	while damage_bar.value > health_bar.value:
		damage_bar.value -= 1
		await get_tree().create_timer(0.05).timeout

func _on_area_2d_body_entered(body):
	if body.name == "Player" and is_alive:
		animated_sprite_2d.play("weapon")
		animated_sprite_2d.frame = random_skin
		player = body
		alert_nearby_enemies()

func _process(_delta):
	if player and is_alive:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player <= detection_range and is_alive:
			ray_cast_2d.look_at(player.global_position)
			animated_sprite_2d.look_at(player.global_position)
			if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() is Player or ray_cast_2d.get_collider() is Objects:
				if can_shoot:
					move_to_player()
					shoot()
					ray_cast_2d.get_collider()
			elif ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() is Enemy:
				follow_player()
			else:
				follow_player()
		else:
			follow_player()
	else:
		player = null

func move_to_player():
	velocity = navigation_agent.get_next_path_position() - global_position
	velocity = velocity.normalized() * speed
	move_and_slide()

func follow_player():
	if player != null and is_alive:
		navigation_agent.target_position = player.global_position
		if navigation_agent.is_target_reached():
			velocity = Vector2.ZERO
		else:
			velocity = navigation_agent.get_next_path_position() - global_position
			velocity = velocity.normalized() * speed
			move_and_slide()
			animated_sprite_2d.look_at(player.global_position)

func shoot():
	if current_ammo == 0:
		reload()
		return
	
	if player.is_alive:
		Audio.play_sound("enemy_shoot")
		can_shoot = false
		current_ammo -= 1
		var miss = randf() < miss_chance
		var angle_offset = 0.0
		if miss:
			angle_offset = deg_to_rad(randf_range(-max_miss_chance, max_miss_chance))
		var bullet = bullet_scene.instantiate() as Area2D
		bullet.modulate = Color("GOLD")
		var marker_position = $AnimatedSprite2D/Marker2D.global_position
		bullet.position = marker_position
		bullet.rotation = (player.global_position - marker_position).angle() + angle_offset
		get_parent().add_child(bullet)
		await get_tree().create_timer(rate_of_fire).timeout
		can_shoot = true

func reload():
	Audio.play_sound("enemy_reload")
	can_shoot = false
	await get_tree().create_timer(1.5).timeout
	current_ammo = max_ammo
	can_shoot = true
