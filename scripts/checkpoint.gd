extends Area2D
@onready var dialog = LevelStructure.get_node("GUI/HUD/Dialog") as Label
@onready var gui_animation = LevelStructure.get_node("AnimationPlayer")
@onready var tutorial_label = LevelStructure.get_node("GUI/TutorialLabel") as Label
@onready var game_state

func _ready():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
	else:
		game_state = GameState
	$Area2D/AnimatedSprite2D.play("offline")

func _on_body_entered(_body):
	game_state.last_pos = global_position - Vector2(50,0)
	game_state.checkpoint_material_count = game_state.material_count
	game_state.checkpoint_broken_boxes = game_state.broken_boxes.duplicate()
	game_state.checkpoint_material_collected = game_state.material_collected.duplicate()
	$Area2D/AnimatedSprite2D.play("online")
	Audio.play_sound("checkpoint_activation")
	gui_animation.play("dialog")
	dialog.text = "Checkpoint reached"
	tutorial_label.text = ""
	await get_tree().create_timer(2.2).timeout
	dialog.text = ""
