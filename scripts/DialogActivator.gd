extends Area2D

@export_multiline var dialog : String
@onready var tutorial_label = LevelStructure.get_node("GUI/TutorialLabel") as Label
@onready var animation_player = LevelStructure.get_node("AnimationPlayer")
@onready var game_state

func _ready():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
	else:
		game_state = GameState

func _on_body_entered(body):
	tutorial_label.text = dialog
	match dialog:
		"Tutorial ended":
			handle_level_end(body, "Level1")
		"Finally I can fix my ship!":
			match get_tree().current_scene.name:
				"Level1":
					handle_level_end(body, "Level2")
				"Level2":
					handle_level_end(body, "Level3")
				"Level3":
					handle_level_end(body, "Level4")
				"Level4":
					handle_level_end(body, "Level5")
				"Level5":
					handle_level_end(body, "Level5")

func handle_level_end(body, next_level):
	if get_tree().current_scene.name == "Level5":
		tutorial_label.text = "I fixed my ship. Now i can get off this planet!"
	body.is_alive = false
	animation_player.play("fadeout")
	LevelStructure.level_ended = true
	Settings.game_progress = next_level
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")
	game_state.reset_stats()
