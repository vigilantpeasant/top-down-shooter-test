extends Area2D
@onready var dialog = LevelStructure.get_node("GUI/HUD/Dialog") as Label
@onready var gui_animation = LevelStructure.get_node("AnimationPlayer")

func _ready():
	$Area2D/AnimatedSprite2D.play("offline")

func _on_body_entered(_body):
	GameState.last_pos = global_position - Vector2(50,0)
	GameState.checkpoint_material_count = GameState.material_count
	$Area2D/AnimatedSprite2D.play("online")
	gui_animation.play("dialog")
	dialog.text = "Checkpoint reached"
	await get_tree().create_timer(2.2).timeout
	dialog.text = ""
