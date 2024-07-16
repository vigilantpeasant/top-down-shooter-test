extends Node2D

@onready var game_state
@onready var tutorial_label = LevelStructure.get_node("GUI/TutorialLabel") as Label

func _on_area_2d_body_entered(_body):
	var current_scene = get_tree().current_scene.name
	if current_scene == "Level4" or current_scene == "Level5":
		if game_state.material_count >= 35:
			$Exit.queue_free()
		else:
			tutorial_label.text = "I need at least 35 materials"
			await get_tree().create_timer(4.0).timeout
			tutorial_label.text = ""
	else:
		if game_state.material_count >= 20:
			$Exit.queue_free()
		else:
			tutorial_label.text = "I need at least 20 materials"
			await get_tree().create_timer(4.0).timeout
			tutorial_label.text = ""

func _enter_tree():
	LevelStructure.scene_start()
	game_state = GameState

	if game_state.last_pos:
		$Player.global_position = game_state.last_pos
		game_state.material_count = game_state.checkpoint_material_count
		game_state.broken_boxes = game_state.checkpoint_broken_boxes.duplicate()
		game_state.material_collected = game_state.checkpoint_material_collected.duplicate()
		
		for box in $Boxes.get_children():
			if box.global_position in game_state.broken_boxes:
				if box.global_position in game_state.material_collected:
					box.queue_free()
				else:
					box.health = 1
					box.visible = true
