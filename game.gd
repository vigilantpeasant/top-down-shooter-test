extends Node2D

func _enter_tree():
	if GameState.last_pos:
		$Player.global_position = GameState.last_pos
		GameState.material_count = GameState.checkpoint_material_count
		for box in $Boxes.get_children():
			if GameState.broken_boxes.has(box.global_position):
				if GameState.material_collected.has(box.global_position):
					box.queue_free()
				else:
					box.health = 1
					box.visible = true
