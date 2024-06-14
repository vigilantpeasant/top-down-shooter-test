extends StaticBody2D

func take_damage(_min_damage : int, _max_damage : int):
	var blood = preload("res://assets/particle.tscn").instantiate() as GPUParticles2D
	blood.modulate = Color(0.545098, 0.270588, 0.0745098, 1)
	get_parent().add_child(blood)
	var direction = (global_position - get_global_mouse_position()).normalized()
	blood.global_position = global_position + direction * 10
	blood.global_rotation = direction.angle()
	blood.emitting = true
	
	call_deferred("drop_material")
	queue_free()
	GameState.broken_boxes[global_position] = true

func drop_material():
	var MaterialInstance = preload("res://assets/material.tscn").instantiate()
	MaterialInstance.global_position = global_position
	get_parent().add_child(MaterialInstance)
