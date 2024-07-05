extends Control
@onready var main_menu = %Main
@onready var settings_menu = %"Settings Menu"
@onready var animation_player = $AnimationPlayer
@onready var gui = LevelStructure.get_node("GUI")
@onready var game_state

func _ready():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
	else:
		game_state = GameState
	
	gui.visible = false
	animation_player.play("appear")
	$Version.text = game_state.game_version

func _on_tutorial_pressed():
	game_state.retry = false
	game_state = TutorialGameState
	get_tree().change_scene_to_file("res://tutorial.tscn")

func _on_play_pressed():
	game_state.retry = false
	game_state = GameState
	get_tree().change_scene_to_file("res://game.tscn")

func _input(_event):
	if Input.is_key_pressed(KEY_ESCAPE):
		animation_player.play("appear")
		main_menu.show()
		settings_menu.hide()

func _on_back_pressed():
	animation_player.play("appear")
	main_menu.show()
	settings_menu.hide()

func _on_settings_pressed():
	main_menu.hide()
	settings_menu.show()

func _on_exit_pressed():
	get_tree().quit()
