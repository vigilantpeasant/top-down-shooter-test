extends Node
var game_version = "v0.8"
var retry = false
var material_count = 0
var last_pos = null
var checkpoint_material_count = 0
var checkpoint_material_collected = {}
var checkpoint_broken_boxes = {}
var broken_boxes = {}
var material_collected = {}
var selected_weapon = "plasma rifle"

func reset_stats():
	material_count = 0
	last_pos = null
	checkpoint_material_count = 0
	checkpoint_material_collected = {}
	checkpoint_broken_boxes = {}
	broken_boxes = {}
	material_collected = {}
	selected_weapon = "plasma rifle"
