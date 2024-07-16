extends CanvasLayer

var hit_particle = preload("res://assets/particle.tres")
var explosion_particle = preload("res://assets/explosion_particle.tres")
var blood_particle = preload("res://assets/blood_particle.tres")
var blood_splash = preload("res://assets/blood_splash.tres")

var materials = [
	hit_particle,
	explosion_particle,
	blood_particle,
	blood_splash,
]

var frames = 0
var loaded = false

func _ready():
	for material in materials:
		var particles_instance = GPUParticles2D.new()
		particles_instance.set_process_material(material)
		particles_instance.set_one_shot(true)
		particles_instance.set_modulate(Color(1, 1, 1, 0))
		particles_instance.set_emitting(true)
		add_child(particles_instance)

func _physics_process(_delta):
	if frames >= 3:
		set_physics_process(false)
		loaded = true
	frames += 1
