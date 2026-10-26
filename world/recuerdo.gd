class_name Recuerdo
extends Area2D
## Fragmento de memoria (moneda del árbol). Los que tienen pickup_id no
## reaparecen una vez recogidos; los soltados por enemigos no tienen id.

signal collected(value: int)

@export var pickup_id: StringName = &""
@export var value: int = 1

var _t: float = 0.0
var _core: Polygon2D
var _base_y: float


func _ready() -> void:
	if pickup_id != &"" and GameState.collected_pickups.has(pickup_id):
		queue_free()
		return
	collision_layer = 128
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 26.0
	cs.shape = c
	add_child(cs)
	var size := 7.0 + value * 2.5
	_core = Polygon2D.new()
	_core.polygon = PackedVector2Array([Vector2(0, -size * 1.4), Vector2(size, 0), Vector2(0, size * 1.4), Vector2(-size, 0)])
	_core.color = Color(2.4, 2.0, 1.0)
	add_child(_core)
	var glow := InkParticles.create(&"recuerdo_glow")
	add_child(glow)
	glow.emitting = true
	var light := PointLight2D.new()
	light.texture = DropTexture.soft()
	light.texture_scale = 2.0 + value * 0.5
	light.color = Color(1.0, 0.85, 0.5)
	light.energy = 0.45
	add_child(light)
	_base_y = position.y
	body_entered.connect(func(b: Node) -> void:
		if b is Player:
			collect())


func _process(delta: float) -> void:
	_t += delta
	position.y = _base_y + sin(_t * 2.4) * 6.0
	if _core:
		_core.rotation = sin(_t * 1.3) * 0.3


func collect() -> void:
	if pickup_id != &"":
		GameState.collected_pickups.append(pickup_id)
	GameState.add_recuerdos(value)
	collected.emit(value)
	_sparkle()
	queue_free()


## Destello dorado que sobrevive al Recuerdo recogido.
func _sparkle() -> void:
	var parent := get_parent()
	if parent == null:
		return
	var p := InkParticles.create(&"hit_glint")
	var m := p.process_material as ParticleProcessMaterial
	m.color = InkParticles.GOLD
	m.spread = 180.0
	p.amount = 14
	parent.add_child(p)
	p.global_position = global_position
	p.emitting = true
	p.finished.connect(p.queue_free)
