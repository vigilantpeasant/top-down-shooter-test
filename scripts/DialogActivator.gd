extends Area2D

@export_multiline var dialog : String
@onready var tutorial_label = LevelStructure.get_node("GUI/TutorialLabel") as Label
@onready var game_state
@onready var animation_player = LevelStructure.get_node("AnimationPlayer")

func _ready():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
	else:
		game_state = GameState

func _on_body_entered(body):
	tutorial_label.text = dialog
	if get_tree().current_scene.name == "Tutorial":
		if dialog == "Tutorial ended":
			await get_tree().create_timer(1.2).timeout
			get_tree().change_scene_to_file("res://main_menu.tscn")
			game_state.reset_stats()
	else:
		if dialog == "Finally I can fix my ship!":
			body.is_alive = false
			animation_player.play("fadeout")
			await get_tree().create_timer(3.0).timeout
			get_tree().change_scene_to_file("res://main_menu.tscn")
			game_state.reset_stats()
