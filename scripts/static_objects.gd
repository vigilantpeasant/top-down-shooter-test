extends StaticBody2D

@export var health : int
@export var can_give_material : bool

func take_damage():
	health -= 1
	if health <= 0:
		if can_give_material == true:
			const MATERIAL = preload("res://material.tscn")
			var new_material = MATERIAL.instantiate()
			#new_material.global_position = 
			pass
		queue_free()
