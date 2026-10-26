class_name DripChain
extends Node2D
## Gota colgante simulada con una cadena verlet. Se dibuja en coordenadas
## globales (top_level) para que se quede atrás con el movimiento.

const ITERATIONS := 8
const GRAVITY := Vector2(0, 1400)
const DAMPING := 0.985

@export var segment_length: float = 3.0
@export var base_width: float = 3.6
@export var color: Color = Color(0.025, 0.025, 0.04)

var anchor: Node2D
var segments: int = 4:
	set(v):
		v = maxi(v, 1)
		if v != segments:
			segments = v
			_reset_points()

var _points: PackedVector2Array = PackedVector2Array()
var _prev: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	top_level = true
	global_transform = Transform2D.IDENTITY
	_reset_points()


func _reset_points() -> void:
	var origin := anchor.global_position if anchor and anchor.is_inside_tree() else Vector2.ZERO
	_points.resize(segments + 1)
	_prev.resize(segments + 1)
	for i in segments + 1:
		_points[i] = origin + Vector2(0, i * segment_length)
		_prev[i] = _points[i]


func _process(delta: float) -> void:
	if anchor == null:
		return
	delta = minf(delta, 1.0 / 30.0)
	_points[0] = anchor.global_position
	_prev[0] = _points[0]
	for i in range(1, _points.size()):
		var p := _points[i]
		var v := (p - _prev[i]) * DAMPING
		_prev[i] = p
		_points[i] = p + v + GRAVITY * delta * delta
	for _k in ITERATIONS:
		for i in range(1, _points.size()):
			var a := _points[i - 1]
			var b := _points[i]
			var d := b - a
			var dist := d.length()
			if dist < 0.0001:
				continue
			var diff := (dist - segment_length) / dist
			if i == 1:
				_points[i] = b - d * diff
			else:
				_points[i - 1] = a + d * diff * 0.5
				_points[i] = b - d * diff * 0.5
		_points[0] = anchor.global_position
	queue_redraw()


func _draw() -> void:
	var n := _points.size()
	for i in range(n - 1):
		# Ancho en el anclaje, estrecho en el cuello y bulbo al final.
		var w := lerpf(base_width, base_width * 0.3, float(i) / float(n - 1))
		draw_line(_points[i], _points[i + 1], color, w, true)
	draw_circle(_points[n - 1], base_width * 0.55, color, true, -1.0, true)
