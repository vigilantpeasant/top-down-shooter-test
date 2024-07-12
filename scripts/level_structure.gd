extends Node2D
@onready var game_state

func _ready():
	scene_start()

func scene_start():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
		$GUI/TutorialLabel.text = "You can always hide/show control reference
E to Show/Hide"
	else:
		game_state = GameState
		$GUI/TutorialLabel.text = "I need to repair my ship. I need at least 20 material"
	
	$GUI/HUD/MaterialPanel/MaterialLabel.text = str(game_state.material_count)

func _process(_delta):
	match (Settings.inoverlay):
		0:
			$GUI/Version.text = game_state.game_version + "\n" + str(Engine.get_frames_per_second())
		1:
			$GUI/Version.text = str(Engine.get_frames_per_second())
		2:
			$GUI/Version.text = game_state.game_version
		3:
			$GUI/Version.text = ""

func _input(event):
	if event.is_action_pressed("interaction"):
		if $"GUI/HUD/Button Prompts".visible == false:
			$"GUI/HUD/Button Prompts".visible = true
			$GUI/HUD/Weapons.position = Vector2(438, -157)
			$GUI/HUD/DashPanel.position = Vector2(506, -80)
			$GUI/HUD/GrenadePanel.position = Vector2(438, -80)
			$GUI/HUD/MeleePanel.position = Vector2(371, -80)
		else:
			$"GUI/HUD/Button Prompts".visible = false
			$GUI/HUD/Weapons.position = Vector2(438, -116)
			$GUI/HUD/DashPanel.position = Vector2(506, -58)
			$GUI/HUD/GrenadePanel.position = Vector2(438, -58)
			$GUI/HUD/MeleePanel.position = Vector2(371, -58)
	
	if event.is_action_pressed("escape"):
		$GUI/TutorialLabel.text = ""
		game_state.retry = false
		get_tree().change_scene_to_file("res://main_menu.tscn")
		if not game_state.last_pos:
			game_state.reset_stats()
		game_state.retry = true
		game_state.material_count = game_state.checkpoint_material_count

func _on_retry_button_down():
	game_state.retry = false
	get_tree().reload_current_scene()
	if not game_state.last_pos:
		game_state.reset_stats()
	game_state.retry = true
	game_state.material_count = game_state.checkpoint_material_count

func _on_main_menu_button_down():
	game_state.retry = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
	game_state.retry = true
