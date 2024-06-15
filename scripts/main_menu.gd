extends Control
@onready var main_menu = %Main
@onready var settings_menu = %"Settings Menu"
@onready var animation_player = $AnimationPlayer
@onready var gui = LevelStructure.get_node("GUI")

func _ready():
	gui.visible = false
	animation_player.play("appear")
	$Version.text = GameState.game_version

func _on_new_game_pressed():
	GameState.retry = false
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
