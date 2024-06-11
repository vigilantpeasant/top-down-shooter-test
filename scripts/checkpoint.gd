extends Area2D
@onready var dialog = $"/root/Main/LevelStructure/GUI/HUD/Dialog" as Label

func _ready():
	$Area2D/AnimatedSprite2D.play("offline")

func _on_body_entered(_body):
	$Area2D/AnimatedSprite2D.play("online")
	dialog.text = "Checkpoint reached"
	await get_tree().create_timer(2.0).timeout
	dialog.text = ""
	GameState.last_pos = global_position
	GameState.checkpoint_material_count = GameState.material_count
