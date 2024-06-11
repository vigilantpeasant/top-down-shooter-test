extends TextureProgressBar

@onready var damage_bar = $DamageBar
@onready var fill_color: Color
@export var damage_fill_color: Color

func _ready():
	var fill_stylebox = StyleBoxFlat.new()
	fill_stylebox.bg_color = fill_color
	self.add_theme_stylebox_override("fill", fill_stylebox)
	
	var fill_stylebox2 = StyleBoxFlat.new()
	fill_stylebox2.bg_color = damage_fill_color
	damage_bar.add_theme_stylebox_override("fill", fill_stylebox2)
