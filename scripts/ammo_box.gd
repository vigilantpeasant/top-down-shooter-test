extends Area2D
@export var type : int
@onready var player : Player

func _on_body_entered(_body):
	player = find_player_node(get_tree().get_root())
	Audio.play_sound("pickup_ammo")
	match type:
		0:
			player.total_pistol_ammo += player.max_total_pistol_ammo
		1:
			player.total_rifle_ammo += player.max_total_rifle_ammo
	create_tween().tween_property(self, "scale", Vector2(1.35, 1.35), 0.2)
	player.update_ammo_text()
	await get_tree().create_timer(0.2).timeout
	call_deferred("queue_free")

func find_player_node(node):
	if node.has_node("Player"):
		return node.get_node("Player")
	
	for child in node.get_children():
		var result = find_player_node(child)
		if result != null:
			return result
	
	return null
