extends Area2D
@onready var dialog = $"/root/Main/LevelStructure/GUI/HUD/Dialog" as Label
@onready var GUI_animation = $"/root/Main/LevelStructure/AnimationPlayer"

func _ready():
	$Area2D/AnimatedSprite2D.play("offline")

func _on_body_entered(_body):
	GameState.last_pos = global_position
	GameState.checkpoint_material_count = GameState.material_count
	$Area2D/AnimatedSprite2D.play("online")
	GUI_animation.play("dialog")
	dialog.text = "Checkpoint reached"
	await get_tree().create_timer(2.2).timeout
	dialog.text = ""
