class_name SlashArc
extends Node2D
## Tajo de tinta: media luna que barre y se desvanece. Núcleo negro y filo
## pálido luminoso (HDR) para que destaque con el glow.

const DURATION := 0.14
const RADIUS := 78.0
const THICKNESS := 26.0
const SWEEP := 2.3

var direction: StringName = &"side"
var facing: int = 1
var _t: float = 0.0


func _ready() -> void:
	match direction:
		&"up":
			rotation = -PI * 0.5
		&"down":
			rotation = PI * 0.5
		_:
			rotation = 0.0 if facing > 0 else PI
	if direction != &"side":
		scale.y = float(facing)


func _process(delta: float) -> void:
	_t += delta
	if _t >= DURATION:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var k := clampf(_t / DURATION, 0.0, 1.0)
	var head := lerpf(-SWEEP * 0.5, SWEEP * 0.5, minf(k * 1.6, 1.0))
	var tail := lerpf(-SWEEP * 0.5, SWEEP * 0.5, maxf(k * 1.6 - 0.6, 0.0))
	var alpha := 1.0 - k * k
	if head - tail < 0.08:
		return
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	var steps := 18
	for i in steps + 1:
		var a := lerpf(tail, head, float(i) / steps)
		# Más grueso en el centro del arco.
		var w := maxf(THICKNESS * sin(PI * float(i) / steps), 1.5)
		outer.append(Vector2(cos(a), sin(a)) * RADIUS)
		inner.append(Vector2(cos(a), sin(a)) * (RADIUS - w))
	var poly := PackedVector2Array(outer)
	for i in range(inner.size() - 1, -1, -1):
		poly.append(inner[i])
	if poly.size() >= 3:
		draw_colored_polygon(poly, Color(0.02, 0.02, 0.035, 0.92 * alpha))
	if outer.size() >= 2:
		draw_polyline(outer, Color(1.5, 1.6, 2.0, alpha), 2.5, true)
