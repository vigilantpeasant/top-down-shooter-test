extends Control
@onready var main_menu = %Main
@onready var settings_menu = %"Settings Menu"

func _on_new_game_pressed(): #when clicked New Game button scene changes to game
	get_tree().change_scene_to_file("res://game.tscn")

func _input(_event):
	if Input.is_key_pressed(KEY_ESCAPE):
		main_menu.show()
		settings_menu.hide()

func _on_back_pressed():
	main_menu.show()
	settings_menu.hide()

func _on_settings_pressed():
	main_menu.hide()
	settings_menu.show()
