extends Node

@onready var box_break = $box_break
@onready var metal_break = $metal_break
@onready var plasma_pistol_shoot = $plasma_pistol_shoot
@onready var plasma_rifle_shoot = $plasma_rifle_shoot
@onready var bullet_hit = $bullet_hit
@onready var enemy_shoot = $enemy_shoot
@onready var explosion = $explosion
@onready var click = $click
@onready var checkpoint_activation = $checkpoint_activation
@onready var dash = $dash
@onready var plasma_reload = $plasma_reload
@onready var slash = $slash
@onready var enemy_reload = $enemy_reload
@onready var pickup_ammo = $pickup_ammo
@onready var pickup_material = $pickup_material

var sfx_dict = {}

func _ready():
	sfx_dict["box_break"] = box_break
	sfx_dict["metal_break"] = metal_break
	sfx_dict["plasma_pistol_shoot"] = plasma_pistol_shoot
	sfx_dict["plasma_rifle_shoot"] = plasma_rifle_shoot
	sfx_dict["bullet_hit"] = bullet_hit
	sfx_dict["enemy_shoot"] = enemy_shoot
	sfx_dict["explosion"] = explosion
	sfx_dict["click"] = click
	sfx_dict["checkpoint_activation"] = checkpoint_activation
	sfx_dict["dash"] = dash
	sfx_dict["plasma_reload"] = plasma_reload
	sfx_dict["slash"] = slash
	sfx_dict["enemy_reload"] = enemy_reload
	sfx_dict["pickup_ammo"] = pickup_ammo
	sfx_dict["pickup_material"] = pickup_material

func play_sound(sfx : String):
	if sfx in sfx_dict:
		sfx_dict[sfx].play()
	else:
		print("Sound effect not found: " + sfx)
