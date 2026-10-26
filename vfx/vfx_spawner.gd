class_name VfxSpawner
extends Node2D
## Crea los efectos visuales en respuesta a señales del juego.

var camera: GameCamera
var decals: SplatterDecals
var _player: Player
var _trail: GPUParticles2D
var _drip: GPUParticles2D


func _ready() -> void:
	decals = SplatterDecals.new()
	decals.z_index = -1
	add_child(decals)
	EventBus.hit_landed.connect(_on_hit_landed)
	EventBus.enemy_killed.connect(func(e: Node) -> void:
		if e is Node2D:
			burst(&"death_burst", (e as Node2D).global_position)
			if camera:
				camera.shake(8.0, 0.2))


func bind_player(p: Player) -> void:
	_player = p
	p.landed.connect(func(impact: float) -> void:
		if impact > 450.0:
			burst(&"land_splash", p.global_position + Vector2(0, Player.HALF_HEIGHT)))
	p.dashed.connect(_on_dashed)
	p.attacked.connect(_on_attacked)
	p.puddle_changed.connect(func(_active: bool) -> void:
		burst(&"puddle_enter", p.global_position + Vector2(0, Player.HALF_HEIGHT - 4)))
	p.hurt.connect(func(_amount: float) -> void:
		burst(&"hit_splash", p.global_position).scale = Vector2(1.3, 1.3)
		if camera:
			camera.shake(12.0, 0.3))
	p.died.connect(func() -> void:
		burst(&"death_burst", p.global_position)
		if camera:
			camera.shake(16.0, 0.5))
	p.healed.connect(func() -> void: burst(&"hit_glint", p.global_position))
	p.ink.overflow_started.connect(func() -> void:
		burst(&"overflow_burst", p.global_position)
		if camera:
			camera.shake(14.0, 0.4))
	_trail = InkParticles.create(&"dash_trail")
	_trail.one_shot = false
	_trail.emitting = false
	add_child(_trail)
	_drip = InkParticles.create(&"drip")
	_drip.amount_ratio = 0.2
	add_child(_drip)


func _physics_process(_delta: float) -> void:
	if _player and is_instance_valid(_player):
		var pos: Vector2 = _player.global_position
		_trail.global_position = pos
		_drip.global_position = pos
		_trail.emitting = _player.sm.current_name() == &"dash"
		_drip.amount_ratio = 0.15 + _player.ink.instability / 100.0 * 0.85
		_drip.emitting = _player.sm.current_name() != &"puddle"


## Lanza un efecto de un solo disparo y lo libera al terminar.
func burst(kind: StringName, pos: Vector2, dir: Vector2 = Vector2.ZERO) -> GPUParticles2D:
	var p := InkParticles.create(kind)
	if dir != Vector2.ZERO:
		var m := p.process_material as ParticleProcessMaterial
		m.direction = Vector3(dir.x, dir.y, 0)
	add_child(p, true)
	p.global_position = pos
	p.restart()
	p.emitting = true
	p.finished.connect(p.queue_free)
	# Respaldo por si 'finished' no llega (p. ej. sin GPU).
	get_tree().create_timer(p.lifetime + 0.5, false).timeout.connect(p.queue_free)
	return p


func _on_hit_landed(pos: Vector2, strength: float) -> void:
	var dir := Vector2.RIGHT
	if _player and is_instance_valid(_player):
		dir = (pos - _player.global_position).normalized()
		if dir == Vector2.ZERO:
			dir = Vector2(_player.facing, 0)
	var splash := burst(&"hit_splash", pos, dir)
	splash.name = "HitSplash"
	burst(&"hit_glint", pos, dir)
	_splat_near(pos, dir, strength)
	if camera:
		camera.shake(5.0 * strength, 0.14)


func _on_dashed() -> void:
	burst(&"puddle_enter", _player.global_position + Vector2(0, Player.HALF_HEIGHT - 4))


func _on_attacked(direction: StringName) -> void:
	var s := SlashArc.new()
	s.direction = direction
	s.facing = _player.facing
	_player.add_child(s)
	match direction:
		&"up":
			s.position = Vector2(0, -40)
		&"down":
			s.position = Vector2(0, 40)
		_:
			s.position = Vector2(_player.facing * 20, 0)


## Proyecta manchas sobre la superficie más cercana en la dirección del golpe.
func _splat_near(pos: Vector2, dir: Vector2, strength: float) -> void:
	var space := get_world_2d().direct_space_state
	for i in 3:
		var d := dir.rotated(randf_range(-0.6, 0.6)) if i > 0 else Vector2.DOWN
		var q := PhysicsRayQueryParameters2D.create(pos, pos + d * 260.0, 1)
		var hit := space.intersect_ray(q)
		if hit:
			decals.add_splat(hit.position, hit.normal, randf_range(0.6, 1.2) * strength)
