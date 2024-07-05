extends StaticBody2D

@onready var game_state
var health = 1

func _ready():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
	else:
		game_state = GameState

func take_damage(_min_damage : int, _max_damage : int):
	health -= 1
	if health <= 0:
		call_deferred("drop_material")
		queue_free()
		game_state.broken_boxes[global_position] = true
	var blood = preload("res://assets/particle.tscn").instantiate() as GPUParticles2D
	blood.modulate = Color("SADDLE_BROWN")
	get_parent().add_child(blood)
	var direction = (global_position - get_global_mouse_position()).normalized()
	blood.global_position = global_position + direction * 10
	blood.global_rotation = direction.angle()
	blood.emitting = true

func drop_material():
	var material_instance = preload("res://assets/material.tscn").instantiate()
	material_instance.global_position = global_position
	get_parent().add_child(material_instance)
