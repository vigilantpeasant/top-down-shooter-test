extends StaticBody2D

var health = 1
const materials = preload("res://assets/material.tscn")

func take_damage():
	health -= 1
	if health <= 0:
		call_deferred("drop_material")
		queue_free()

func drop_material():
	var material_instance = materials.instantiate()
	material_instance.global_position = global_position
	get_parent().add_child(material_instance)
