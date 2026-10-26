class_name InkParticles
## Fábrica de efectos de partículas por GPU. Cada tipo es un GPUParticles2D
## configurado; los de un solo disparo se liberan solos (ver VfxSpawner.burst).

const INK := Color(0.02, 0.02, 0.035, 1.0)
const GLINT := Color(1.6, 1.7, 2.1, 1.0)
const GOLD := Color(2.2, 1.8, 0.9, 1.0)
const OVERFLOW_A := Color(1.6, 0.4, 2.6, 1.0)
const OVERFLOW_B := Color(2.6, 0.3, 0.6, 1.0)

const KINDS: Array[StringName] = [&"hit_splash", &"hit_glint", &"land_splash", &"dash_trail",
		&"drip", &"overflow_burst", &"ambient_ash", &"recuerdo_glow", &"puddle_enter", &"death_burst",
		&"spores"]


static func create(kind: StringName) -> GPUParticles2D:
	var p := GPUParticles2D.new()
	var m := ParticleProcessMaterial.new()
	m.particle_flag_disable_z = true
	p.process_material = m
	p.texture = DropTexture.hard()
	p.local_coords = false
	p.one_shot = true
	p.explosiveness = 1.0
	p.fixed_fps = 0
	p.interpolate = true
	p.draw_order = GPUParticles2D.DRAW_ORDER_LIFETIME
	match kind:
		&"hit_splash":
			_ink(p, m, 28, 0.65)
			m.direction = Vector3(1, -0.3, 0)
			m.spread = 55.0
			m.initial_velocity_min = 280.0
			m.initial_velocity_max = 950.0
			m.gravity = Vector3(0, 1700, 0)
			m.damping_min = 40.0
			m.damping_max = 120.0
			m.scale_min = 0.05
			m.scale_max = 0.22
		&"hit_glint":
			p.amount = 8
			p.lifetime = 0.22
			p.texture = DropTexture.soft()
			m.direction = Vector3(1, 0, 0)
			m.spread = 70.0
			m.initial_velocity_min = 600.0
			m.initial_velocity_max = 1400.0
			m.damping_min = 2500.0
			m.damping_max = 3500.0
			m.scale_min = 0.015
			m.scale_max = 0.045
			m.color = GLINT
			m.scale_curve = _shrink_curve()
		&"land_splash":
			_ink(p, m, 14, 0.45)
			m.direction = Vector3(0, -1, 0)
			m.spread = 80.0
			m.initial_velocity_min = 120.0
			m.initial_velocity_max = 380.0
			m.gravity = Vector3(0, 1500, 0)
			m.scale_min = 0.04
			m.scale_max = 0.13
			m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			m.emission_box_extents = Vector3(22, 2, 0)
		&"dash_trail":
			_ink(p, m, 36, 0.4)
			p.explosiveness = 0.0
			m.direction = Vector3(0, -1, 0)
			m.spread = 180.0
			m.initial_velocity_min = 10.0
			m.initial_velocity_max = 90.0
			m.gravity = Vector3(0, 500, 0)
			m.scale_min = 0.06
			m.scale_max = 0.2
			m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			m.emission_box_extents = Vector3(10, 34, 0)
		&"drip":
			_ink(p, m, 10, 0.9)
			p.one_shot = false
			p.explosiveness = 0.0
			m.direction = Vector3(0, 1, 0)
			m.spread = 10.0
			m.initial_velocity_min = 0.0
			m.initial_velocity_max = 30.0
			m.gravity = Vector3(0, 900, 0)
			m.scale_min = 0.03
			m.scale_max = 0.07
			m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			m.emission_box_extents = Vector3(16, 30, 0)
		&"overflow_burst":
			p.amount = 90
			p.lifetime = 0.9
			p.texture = DropTexture.soft()
			m.direction = Vector3(0, -1, 0)
			m.spread = 180.0
			m.initial_velocity_min = 250.0
			m.initial_velocity_max = 800.0
			m.damping_min = 900.0
			m.damping_max = 1500.0
			m.scale_min = 0.03
			m.scale_max = 0.12
			m.color_ramp = _ramp([OVERFLOW_A, OVERFLOW_B, Color(OVERFLOW_B, 0.0)])
			m.scale_curve = _shrink_curve()
		&"ambient_ash":
			p.one_shot = false
			p.explosiveness = 0.0
			p.amount = 70
			p.lifetime = 9.0
			p.preprocess = 9.0
			p.texture = DropTexture.soft()
			m.direction = Vector3(0.3, 1, 0)
			m.spread = 30.0
			m.initial_velocity_min = 15.0
			m.initial_velocity_max = 45.0
			m.gravity = Vector3(0, 6, 0)
			m.turbulence_enabled = true
			m.turbulence_noise_strength = 4.0
			m.turbulence_noise_scale = 3.0
			m.scale_min = 0.015
			m.scale_max = 0.05
			m.color_ramp = _ramp([Color(0.85, 0.85, 0.9, 0.0), Color(0.85, 0.85, 0.9, 0.55), Color(0.85, 0.85, 0.9, 0.0)])
			m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			m.emission_box_extents = Vector3(1200, 700, 0)
		&"recuerdo_glow":
			p.one_shot = false
			p.explosiveness = 0.0
			p.amount = 16
			p.lifetime = 1.4
			p.texture = DropTexture.soft()
			m.direction = Vector3(0, -1, 0)
			m.spread = 40.0
			m.initial_velocity_min = 10.0
			m.initial_velocity_max = 40.0
			m.gravity = Vector3(0, -20, 0)
			m.scale_min = 0.03
			m.scale_max = 0.08
			m.color_ramp = _ramp([Color(GOLD, 0.0), GOLD, Color(GOLD, 0.0)])
			m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
			m.emission_sphere_radius = 18.0
		&"puddle_enter":
			_ink(p, m, 18, 0.4)
			m.direction = Vector3(0, -1, 0)
			m.spread = 75.0
			m.initial_velocity_min = 150.0
			m.initial_velocity_max = 420.0
			m.gravity = Vector3(0, 1800, 0)
			m.scale_min = 0.04
			m.scale_max = 0.14
			m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			m.emission_box_extents = Vector3(30, 4, 0)
		&"death_burst":
			_ink(p, m, 60, 1.1)
			m.direction = Vector3(0, -1, 0)
			m.spread = 180.0
			m.initial_velocity_min = 200.0
			m.initial_velocity_max = 900.0
			m.gravity = Vector3(0, 1400, 0)
			m.scale_min = 0.06
			m.scale_max = 0.3
		&"spores":
			p.one_shot = false
			p.explosiveness = 0.0
			p.amount = 40
			p.lifetime = 7.0
			p.preprocess = 7.0
			p.texture = DropTexture.soft()
			m.direction = Vector3(0, -1, 0)
			m.spread = 60.0
			m.initial_velocity_min = 8.0
			m.initial_velocity_max = 25.0
			m.gravity = Vector3(0, -4, 0)
			m.turbulence_enabled = true
			m.turbulence_noise_strength = 3.0
			m.scale_min = 0.02
			m.scale_max = 0.05
			m.color_ramp = _ramp([Color(OVERFLOW_A, 0.0), Color(OVERFLOW_A, 0.5), Color(OVERFLOW_A, 0.0)])
			m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
			m.emission_box_extents = Vector3(1200, 700, 0)
		_:
			push_warning("InkParticles: tipo desconocido %s" % kind)
			p.free()
			return null
	p.name = String(kind).to_pascal_case()
	return p


static func _ink(p: GPUParticles2D, m: ParticleProcessMaterial, amount: int, lifetime: float) -> void:
	p.texture = DropTexture.streak()
	m.particle_flag_align_y = true
	p.amount = amount
	p.lifetime = lifetime
	m.color = INK
	m.scale_curve = _shrink_curve()


static func _shrink_curve() -> CurveTexture:
	var c := Curve.new()
	c.add_point(Vector2(0.0, 1.0))
	c.add_point(Vector2(0.7, 0.8))
	c.add_point(Vector2(1.0, 0.0))
	var t := CurveTexture.new()
	t.curve = c
	return t


static func _ramp(colors: Array) -> GradientTexture1D:
	var g := Gradient.new()
	var offs := PackedFloat32Array()
	for i in colors.size():
		offs.append(float(i) / float(colors.size() - 1))
	g.offsets = offs
	g.colors = PackedColorArray(colors)
	var t := GradientTexture1D.new()
	t.gradient = g
	return t
