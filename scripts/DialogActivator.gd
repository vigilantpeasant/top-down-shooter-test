extends Area2D

signal animation_ended
@export var dialog_id : int
@onready var tutorial_label = LevelStructure.get_node("GUI/HUD/TutorialLabel") as Label
@onready var dialog_label = LevelStructure.get_node("GUI/HUD/Dialog") as Label
@onready var gui_animation = LevelStructure.get_node("AnimationPlayer")
@onready var game_state

func _ready():
	if get_tree().current_scene.name == "Tutorial":
		game_state = TutorialGameState
	else:
		game_state = GameState

func _on_body_entered(_body):
	if get_tree().current_scene.name == "Tutorial":
		match dialog_id:
			0:
				gui_animation.play("dialog")
				dialog_label.text = "I need to repair my ship"
			1:
				gui_animation.play("dialog")
				dialog_label.text = "I can break these boxes and get material"
				tutorial_label.text = "LEFT CLICK TO MELEE ATTACK"
			2:
				tutorial_label.text = "You can SAVE the game with checkpoints. However, these checkpoints will be DELETED when you exit the game."
			3:
				tutorial_label.text = "RIGHT CLICK TO AIM and \n LEFT CLICK TO SHOT "
			4:
				tutorial_label.text = "Don't forget use dash ability and reload \n SPACE TO DASH \n R TO RELOAD"
			5:
				tutorial_label.text = "You can use grenade for larger group of enemies \n G TO THROW GRENADE"
			6:
				tutorial_label.text = "You can change your weapon \n 1 TO RIFLE and 2 TO PISTOL"
			7:
				tutorial_label.text = "You can shoot barrels and watch them explode."
			8:
				tutorial_label.text = "Tutorial ended"
				await get_tree().create_timer(1.2).timeout
				get_tree().change_scene_to_file("res://main_menu.tscn")
				game_state.reset_stats()
		animation_ended.emit()

func _on_animation_ended():
	queue_free()
