extends Area2D

const BULLET_SPEED = 500
const BULLET_RANGE = 1200
var TRAVELLED_DISTANCE = 200
var direction : Vector2

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta): 
	position += direction * BULLET_SPEED * delta
	TRAVELLED_DISTANCE += BULLET_SPEED * delta
	if TRAVELLED_DISTANCE > BULLET_RANGE:
		queue_free()

func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
