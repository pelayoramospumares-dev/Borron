class_name EnemyBody
extends CanvasGroup
## Silueta de tinta de un enemigo: polígonos fusionados con el shader de tinta.

const SHADER := preload("res://player/body/ink_body.gdshader")

var _mat: ShaderMaterial
var _flash: float = 0.0


func _init() -> void:
	fit_margin = 16.0
	_mat = ShaderMaterial.new()
	_mat.shader = SHADER
	_mat.set_shader_parameter(&"wobble_amount", 2.0)
	material = _mat


func flash() -> void:
	_flash = 1.0


func set_wobble(v: float) -> void:
	_mat.set_shader_parameter(&"wobble_amount", v)


func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash = move_toward(_flash, 0.0, delta / 0.06)
		_mat.set_shader_parameter(&"flash", _flash)


## Crea un polígono negro hijo de `parent`.
static func poly(parent: Node, points: Array, color := Color(0, 0, 0)) -> Polygon2D:
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array(points)
	p.color = color
	p.antialiased = true
	parent.add_child(p)
	return p


## Elipse aproximada como lista de puntos.
static func ellipse(center: Vector2, radii: Vector2, steps: int = 16) -> Array:
	var pts: Array = []
	for i in steps:
		var a := TAU * i / steps
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	return pts
