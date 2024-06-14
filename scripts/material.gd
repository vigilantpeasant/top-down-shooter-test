extends Area2D
@onready var material_label = $"/root/Main/LevelStructure/GUI/HUD/MaterialPanel/MaterialLabel"

func _ready():
	GameState.retry = false
	if GameState.retry:
		GameState.material_count = 0
	material_label.text = str(GameState.material_count)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		create_tween().tween_property(self, "scale", Vector2(1.35, 1.35), 0.2)
		GameState.material_count += 1
		material_label.text = str(GameState.material_count)
		await get_tree().create_timer(0.2).timeout
		call_deferred("queue_free")
		GameState.material_collected[self.global_position] = true
