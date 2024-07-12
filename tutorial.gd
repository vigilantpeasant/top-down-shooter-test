extends Node2D
@onready var game_state

func _enter_tree():
	LevelStructure.scene_start()
	game_state = TutorialGameState
	
	if game_state.last_pos:
		$Player.global_position = game_state.last_pos
		game_state.material_count = game_state.checkpoint_material_count
		game_state.broken_boxes = game_state.checkpoint_broken_boxes.duplicate()
		game_state.material_collected = game_state.checkpoint_material_collected.duplicate()
		for box in $Boxes.get_children():
			print("Box: ", box)
			print("Box's Parent: ",box.get_parent())
			print("Box's Health: ", box.health)
			if box.global_position in game_state.broken_boxes:
				if box.global_position in game_state.material_collected:
					box.queue_free()
				else:
					box.health = 1
					box.visible = true
