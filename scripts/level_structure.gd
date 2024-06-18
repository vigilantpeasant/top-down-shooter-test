extends Node2D

func _ready():
	$GUI/HUD/MaterialPanel/MaterialLabel.text = str(GameState.material_count)

func _process(_delta):
	$GUI/Version.text = GameState.game_version + "\n" + str(Engine.get_frames_per_second())

func _input(event):
	pass
	if event.is_action_pressed("interaction"):
		if $"GUI/HUD/Button Prompts".visible == false:
			$"GUI/HUD/Button Prompts".visible = true
			$GUI/HUD/Weapons.position = Vector2(438, -157)
			$GUI/HUD/DashPanel.position = Vector2(506, -80)
			$GUI/HUD/GrenadePanel.position = Vector2(438, -80)
		else:
			$"GUI/HUD/Button Prompts".visible = false
			$GUI/HUD/Weapons.position = Vector2(438, -116)
			$GUI/HUD/DashPanel.position = Vector2(506, -58)
			$GUI/HUD/GrenadePanel.position = Vector2(438, -58)

func _on_retry_button_down():
	GameState.retry = false
	get_tree().reload_current_scene()
	GameState.retry = true
	GameState.material_count = GameState.checkpoint_material_count

func _on_main_menu_button_down():
	GameState.retry = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
	GameState.retry = true
