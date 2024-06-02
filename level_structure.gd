extends Node2D
@onready var reset_material = $Material

func _on_retry_button_down():
	reset_material.retry = false
	reset_material.reset_material_count()
	get_tree().reload_current_scene()
	reset_material.retry = true

func _on_main_menu_button_down():
	reset_material.retry = false
	reset_material.reset_material_count()
	get_tree().change_scene_to_file("res://main_menu.tscn")
	reset_material.retry = true
