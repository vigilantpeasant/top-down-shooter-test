extends Area2D

static var material_count = 0
var retry : bool
@onready var material_label = get_node("/root/Main/LevelStructure/GUI/MaterialLabel")

func _ready():
	if retry == true:
		reset_material_count()

func reset_material_count():
	material_count = 0
	material_label.text = "Material: " + str(material_count)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		material_count += 1
		material_label.text = "Material: " + str(material_count)
		call_deferred("queue_free")
