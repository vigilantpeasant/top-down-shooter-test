extends Area2D

var travelled_distance = 200
const bullet_speed = 500
const bullet_range = 1200
var direction : Vector2

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)

func _physics_process(delta): 
	
	position += direction * bullet_speed * delta
	
	travelled_distance += bullet_speed * delta
	if travelled_distance > bullet_range:
		queue_free()

func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
