extends Control

@onready var stage_select = %"Stage Select"
@onready var main_menu = %Main
@onready var settings_menu = %"Settings Menu"
@onready var animation_player = $AnimationPlayer
@onready var gui = LevelStructure.get_node("GUI")
@onready var game_state
@onready var inoverlay_option = $"Settings Menu/Panel/VBoxContainer/GridContainer2/OptionButton"
@onready var fullscreen_option = $"Settings Menu/Panel/VBoxContainer/GridContainer3/CheckButton"
@onready var vsync_option = $"Settings Menu/Panel/VBoxContainer/GridContainer3/CheckButton2"
@onready var autoreload_option = $"Settings Menu/Panel/VBoxContainer/GridContainer2/CheckButton"
@onready var sfx_bus = AudioServer.get_bus_index("SFX")
@onready var sfx_option = $"Settings Menu/Panel/VBoxContainer/GridContainer/CheckButton"
@onready var item_list = $"Stage Select/ItemList"

func _physics_process(_delta):
	if ParticleCache.loaded:
		set_physics_process(false)
		if get_tree().current_scene.name == "Tutorial":
			game_state = TutorialGameState
		else:
			game_state = GameState
		
		if LevelStructure.level_ended:
			stage_select.show()
			main_menu.hide()
			settings_menu.hide()
			LevelStructure.level_ended = false
		
		check_level_progress()
		update_settings_ui()
		gui.visible = false
		animation_player.play("appear")
		$Version.text = game_state.game_version

func check_level_progress():
	match Settings.game_progress:
		"Level1":
			item_list.set_item_disabled(1, false)
		"Level2":
			item_list.set_item_disabled(1, false)
			item_list.set_item_disabled(2, false)
		"Level3":
			item_list.set_item_disabled(1, false)
			item_list.set_item_disabled(2, false)
			item_list.set_item_disabled(3, false)
		"Level4":
			item_list.set_item_disabled(1, false)
			item_list.set_item_disabled(2, false)
			item_list.set_item_disabled(3, false)
			item_list.set_item_disabled(4, false)
		"Level5":
			item_list.set_item_disabled(1, false)
			item_list.set_item_disabled(2, false)
			item_list.set_item_disabled(3, false)
			item_list.set_item_disabled(4, false)
			item_list.set_item_disabled(5, false)

func update_settings_ui():
	sfx_option.button_pressed = Settings.sfx
	inoverlay_option.selected = Settings.inoverlay
	fullscreen_option.button_pressed = Settings.is_fullscreen
	vsync_option.button_pressed = Settings.is_vsync
	autoreload_option.button_pressed = Settings.autoreload

func _on_play_pressed():
	Audio.play_sound("click")
	stage_select.show()
	main_menu.hide()
	settings_menu.hide()

func _on_back_pressed():
	Audio.play_sound("click")
	main_menu.show()
	$GameName.show()
	settings_menu.hide()
	stage_select.hide()

func _on_settings_pressed():
	Audio.play_sound("click")
	settings_menu.show()
	main_menu.hide()
	$GameName.hide()
	stage_select.hide()

func _on_exit_pressed():
	Audio.play_sound("click")
	get_tree().quit()

func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	Audio.play_sound("click")
	match index:
		0:
			game_state.retry = false
			game_state = TutorialGameState
			get_tree().change_scene_to_file("res://tutorial.tscn")
		1:
			game_state.retry = false
			game_state = GameState
			get_tree().change_scene_to_file("res://levels/level1.tscn")
		2:
			game_state.retry = false
			game_state = GameState
			get_tree().change_scene_to_file("res://levels/level2.tscn")
		3:
			game_state.retry = false
			game_state = GameState
			get_tree().change_scene_to_file("res://levels/level3.tscn")
		4:
			game_state.retry = false
			game_state = GameState
			get_tree().change_scene_to_file("res://levels/level4.tscn")
		5:
			game_state.retry = false
			game_state = GameState
			get_tree().change_scene_to_file("res://levels/level5.tscn")

func _on_autoreload_button_pressed():
	Audio.play_sound("click")
	Settings.autoreload = not Settings.autoreload

func _on_fullscreen_pressed():
	Audio.play_sound("click")
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		Settings.is_fullscreen = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		Settings.is_fullscreen = true

func _on_vsync_pressed():
	Audio.play_sound("click")
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Settings.is_vsync = false
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		Settings.is_vsync = true

func _on_in_overlay_item_selected(index):
	Audio.play_sound("click")
	Settings.inoverlay = index

func _on_sfx_mute_pressed():
	Audio.play_sound("click")
	Settings.sfx = not Settings.sfx
	AudioServer.set_bus_mute(sfx_bus, not Settings.sfx)
