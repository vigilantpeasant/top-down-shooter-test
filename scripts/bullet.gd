extends Area2D

const BULLET_SPEED = 650
var bullet_range = 1000
var travelled_distance = 200
var direction : Vector2

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)
	if GameState.selected_weapon == "plasma pistol":
		bullet_range = 750
	else:
		bullet_range = 1000

func _physics_process(delta): 
	position += direction * BULLET_SPEED * delta
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > bullet_range:
		queue_free()

func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		if body.is_in_group("Player"):
			body.take_damage(3, 10, global_position)
		elif body.is_in_group("Enemy"):
			if GameState.selected_weapon == "plasma rifle":
				body.take_damage(7, 15, global_position)
			else:
				body.take_damage(10, 15, global_position)
		elif body.is_in_group("One-Shot"):
			body.take_damage(1, 1, global_position)
