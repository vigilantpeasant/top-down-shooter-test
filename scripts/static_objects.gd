extends StaticBody2D
@export var health : int

func take_damage():
	health -= 1
	if health <= 0:
		queue_free()
