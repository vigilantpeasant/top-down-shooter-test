extends StaticBody2D
class_name Objects

@onready var game_state
@export var health = 1
@export var can_give_material : bool
@export var material_number : int
@export var color : Color
@export var type : String
var random_skin: int
var blood_scene = preload("res://assets/particle.tscn")
var material_scene = preload("res://assets/material.tscn")

func _ready():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
	else:
		game_state = GameState
	
	if type:
		random_skin = randi_range(0, 2)
		$AnimatedSprite2D.frame = random_skin
		if type == "Storage_Tank":
			if random_skin == 1:
				$CollisionShape2D.shape.size = Vector2(192, 329)

func take_damage(_min_damage : int, _max_damage : int, hit_position : Vector2):
	health -= 1
	if health <= 0:
		if can_give_material:
			call_deferred("drop_material")
		game_state.broken_boxes[global_position] = true
		queue_free()
	var blood = blood_scene.instantiate() as GPUParticles2D
	blood.modulate = color
	get_parent().add_child(blood)
	var direction = (global_position - hit_position).normalized()
	blood.global_position = hit_position
	blood.global_rotation = direction.angle()
	blood.emitting = true

func drop_material():
	for i in range(material_number):
		var material_instance = material_scene.instantiate()
		var animated_sprite_2d = material_instance.get_node("AnimatedSprite2D")
		if material_number > 1:
			animated_sprite_2d.frame = 1
		else:
			animated_sprite_2d.frame = 0
		material_instance.global_position = global_position
		get_parent().add_child(material_instance)
