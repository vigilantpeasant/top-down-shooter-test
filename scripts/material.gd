extends Area2D
@onready var material_label = LevelStructure.get_node("GUI/HUD/MaterialPanel/MaterialLabel")
@onready var game_state

func _ready():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
	else:
		game_state = GameState
	
	game_state.retry = false
	if game_state.retry:
		game_state.material_count = 0
	material_label.text = str(game_state.material_count)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		create_tween().tween_property(self, "scale", Vector2(1.35, 1.35), 0.2)
		game_state.material_count += 1
		material_label.text = str(game_state.material_count)
		game_state.material_collected[self.global_position] = true
		await get_tree().create_timer(0.2).timeout
		call_deferred("queue_free")
