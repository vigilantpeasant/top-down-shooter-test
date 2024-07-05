extends StaticBody2D

var health = 1

func take_damage(_min_damage : int, _max_damage : int):
	health -= 1
	if health <= 0:
		$Barrel2D.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		explode()

func explode():
	$Barrel2D.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	$Area2D.visible = true
	$Area2D.monitoring = true
	$Area2D/GPUParticles2D.emitting = true
	
	await get_tree().create_timer(0.2).timeout
	create_tween().tween_property($Area2D, "modulate", Color.TRANSPARENT, 0.5)
	$Area2D.monitoring = false
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_area_2d_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(10, 25)
