extends Node2D
@onready var game_state
@onready var tutorial_label = LevelStructure.get_node("GUI/TutorialLabel") as Label

func _on_area_2d_body_entered(_body):
	if game_state.material_count >= 20:
		$StaticBody2D/CollisionShape2D.call_deferred("set_disabled", true)
		$StaticBody2D/Sprite2D.visible = false
	else:
		tutorial_label.text = "I need at least 20 material"
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
