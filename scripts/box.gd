extends StaticBody2D

var health = 1

func take_damage():
	health -= 1
	if health <= 0:
		call_deferred("drop_material")
		queue_free()

func drop_material():
	var MaterialInstance = preload("res://assets/material.tscn").instantiate()
	MaterialInstance.global_position = global_position
	get_parent().add_child(MaterialInstance)
