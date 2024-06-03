extends Node2D

func _on_retry_button_down():
	GameState.retry = false
	get_tree().reload_current_scene()
	GameState.retry = true

func _on_main_menu_button_down():
	GameState.retry = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
	GameState.retry = true

func _ready():
	# Reset material count after scene load
	GameState.material_count = 0
