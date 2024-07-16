extends Control

@onready var game_state
@onready var sfx_bus = AudioServer.get_bus_index("SFX")
var level_ended = false

func _ready():
	scene_start()

func scene_start():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
		$GUI/TutorialLabel.text = "You can always hide/show control reference\nE to Show/Hide"
	else:
		game_state = GameState
		var current_scene = get_tree().current_scene.name
		if current_scene == "Level4" or current_scene == "Level5":
			$GUI/TutorialLabel.text = "I need to repair my ship. I need at least 35 materials"
		else:
			$GUI/TutorialLabel.text = "I need to repair my ship. I need at least 20 materials"
	
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
	
	if event.is_action_pressed("mute"):
		Settings.sfx = not Settings.sfx
		AudioServer.set_bus_mute(sfx_bus, not Settings.sfx)
	
	if event.is_action_pressed("escape"):
		$GUI/TutorialLabel.text = ""
		game_state.retry = false
		get_tree().change_scene_to_file("res://main_menu.tscn")
		if not game_state.last_pos:
			game_state.reset_stats()
		game_state.retry = true
		game_state.material_count = game_state.checkpoint_material_count
	if event.is_action_pressed("escape") and LevelStructure.level_ended:
		$AnimationPlayer.play("RESET")

func on_death():
	$AnimationPlayer.play("game_over")
	$GUI/HUD.hide()
	$GUI/GameOver.show()
	$GUI/TutorialLabel.text = ""

func on_start():
	$GUI.show()
	$GUI/HUD.show()
	$GUI/GameOver.hide()

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

func _on_exit_pressed():
	get_tree().quit()
