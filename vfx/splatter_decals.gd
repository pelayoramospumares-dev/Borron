class_name SplatterDecals
extends Node2D
## Manchas de tinta temporales en el escenario. Máximo MAX_SPLATS; se desvanecen.

const MAX_SPLATS := 64
const LIFETIME := 20.0
const FADE := 3.0


func add_splat(pos: Vector2, normal: Vector2, size: float) -> void:
	while get_child_count() >= MAX_SPLATS:
		var oldest := get_child(0)
		remove_child(oldest)
		oldest.queue_free()
	var poly := Polygon2D.new()
	var pts := PackedVector2Array()
	var n := 14
	var r := 10.0 * size
	for i in n:
		var a := TAU * i / n
		var rr := r * randf_range(0.6, 1.25)
		pts.append(Vector2(cos(a) * rr * 1.9, sin(a) * rr * 0.55))
	poly.polygon = pts
	poly.color = Color(0.02, 0.02, 0.035, 0.9)
	poly.antialiased = true
	poly.position = pos
	poly.rotation = normal.angle() + PI * 0.5
	add_child(poly)
	var tw := poly.create_tween()
	tw.tween_interval(LIFETIME - FADE)
	tw.tween_property(poly, ^"modulate:a", 0.0, FADE)
	tw.tween_callback(poly.queue_free)
