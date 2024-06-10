extends Area2D
@onready var material_label = $"/root/Main/LevelStructure/GUI/HUD/Hud/MaterialLabel"

func _ready():
	GameState.retry = false
	if GameState.retry:
		GameState.material_count = 0
	material_label.text = str(GameState.material_count)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		GameState.material_count += 1
		material_label.text = str(GameState.material_count)
		call_deferred("queue_free")
