extends RigidBody2D

var GRENADE_SPEED = 650
const DECELERATION = 900

var travelled_distance = 0
var direction : Vector2
var current_velocity
var explosion_scene = preload("res://assets/explosion_particle.tscn")

func _ready():
	add_collision_exception_with(self)
	direction = Vector2.RIGHT.rotated(rotation)
	linear_velocity = direction * GRENADE_SPEED
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.3

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if GRENADE_SPEED > 0:
		current_velocity = state.linear_velocity
		travelled_distance += current_velocity.length() * state.step
		GRENADE_SPEED -= DECELERATION * state.step
		if GRENADE_SPEED < 0:
			GRENADE_SPEED = 0
		linear_velocity = current_velocity.normalized() * GRENADE_SPEED
	else:
		create_explosion()

func create_explosion():
	GRENADE_SPEED = 0
	$GrenadeSprite.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	sleeping = true
	$Area2D.visible = true
	$Area2D.monitoring = true
	
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	$Area2D/GPUParticles2D.emitting = true

	await get_tree().create_timer(0.2).timeout
	create_tween().tween_property($Area2D, "modulate", Color.TRANSPARENT, 0.5)
	$Area2D.monitoring = false
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_explosion_site_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(15, 35, global_position)

func take_damage(_min_damage : int, _max_damage : int, _hit_position : Vector2):
	linear_velocity = current_velocity.normalized() * GRENADE_SPEED
