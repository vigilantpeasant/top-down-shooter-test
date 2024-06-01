extends ProgressBar
@export var fill_color: Color

func _ready():
	var fill_stylebox = StyleBoxFlat.new()
	fill_stylebox.bg_color = fill_color
	self.add_theme_stylebox_override("fill", fill_stylebox)
