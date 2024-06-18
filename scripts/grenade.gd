extends RigidBody2D

var GRENADE_SPEED = 650
const GRENADE_RANGE = 1500
const DECELERATION = 600

var travelled_distance = 0
var direction : Vector2
var has_hit_enemy = false

func _ready():
	add_collision_exception_with(self)
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta):
	if not has_hit_enemy:
		if GRENADE_SPEED > 0:
			position += direction * GRENADE_SPEED * delta
			travelled_distance += GRENADE_SPEED * delta
			GRENADE_SPEED -= DECELERATION * delta
			if GRENADE_SPEED < 0:
				GRENADE_SPEED = 0
		else:
			_create_explosion()

func _create_explosion():
	GRENADE_SPEED = 0
	await get_tree().create_timer(0.1).timeout
	$GrenadeSprite.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	sleeping = true
	$Area2D.visible = true
	$Area2D.monitoring = true
	$Area2D/GPUParticles2D.emitting = true
	
	await get_tree().create_timer(0.2).timeout
	create_tween().tween_property($Area2D, "modulate", Color.TRANSPARENT, 1.0)
	$Area2D.monitoring = false
	await get_tree().create_timer(1.0).timeout
	queue_free()

func _on_body_entered(_body):
	has_hit_enemy = true
	GRENADE_SPEED = 0
	_create_explosion()

func _on_explosion_site_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(15, 35)

func take_damage(_min_damage : int, _max_damage : int):
	_create_explosion()
