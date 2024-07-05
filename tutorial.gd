extends Node2D
@onready var game_state

func _enter_tree():
	LevelStructure.scene_start()
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
	else:
		game_state = GameState
	
	if game_state.last_pos:
		$Player.global_position = game_state.last_pos
		game_state.material_count = game_state.checkpoint_material_count
		game_state.broken_boxes = game_state.checkpoint_broken_boxes.duplicate()  # Restore broken boxes state
		game_state.material_collected = game_state.checkpoint_material_collected.duplicate()  # Restore collected materials state
		
		for box in $Boxes.get_children():
			if box.global_position in game_state.broken_boxes:
				if box.global_position in game_state.material_collected:
					box.queue_free()
				else:
					box.health = 1
					box.visible = true
