extends Node2D

func _ready():
	$GUI/HUD/MaterialPanel/MaterialLabel.text = str(GameState.material_count)

func _process(_delta):
	$GUI/Version.text = GameState.game_version + "\n" + str(Engine.get_frames_per_second())

func _on_retry_button_down():
	GameState.retry = false
	get_tree().reload_current_scene()
	GameState.retry = true
	GameState.material_count = GameState.checkpoint_material_count

func _on_main_menu_button_down():
	GameState.retry = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
	GameState.retry = true
