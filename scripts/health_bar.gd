extends ProgressBar
@export var fill_color: Color

func _ready():
	# Sağlık çubuğunun fill stilini ayarla
	var fill_stylebox = StyleBoxFlat.new()
	fill_stylebox.bg_color = fill_color
	self.add_theme_stylebox_override("fill", fill_stylebox)
