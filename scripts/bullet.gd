extends Area2D

const BULLET_SPEED = 650
const BULLET_RANGE = 1200
var travelled_distance = 200
var direction : Vector2

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta): 
	position += direction * BULLET_SPEED * delta
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > BULLET_RANGE:
		queue_free()

func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		if body.is_in_group("Player"):
			body.take_damage(5, 10)
		elif body.is_in_group("Enemy"):
			body.take_damage(10, 15)
		elif body.is_in_group("Box"):
			body.take_damage(1, 1)
