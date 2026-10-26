class_name DropTexture
## Texturas suaves generadas por código para las partículas (sin píxeles).

static var _soft: Texture2D
static var _hard: Texture2D
static var _streak: Texture2D


## Gota redonda con borde difuminado.
static func soft() -> Texture2D:
	if _soft == null:
		_soft = _radial(PackedFloat32Array([0.0, 0.55, 1.0]),
				PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.85), Color(1, 1, 1, 0)]))
	return _soft


## Gota casi sólida con borde fino (para tinta).
static func hard() -> Texture2D:
	if _hard == null:
		_hard = _radial(PackedFloat32Array([0.0, 0.78, 1.0]),
				PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)]))
	return _hard


## Gota alargada (vertical) para alinear con la velocidad.
static func streak() -> Texture2D:
	if _streak == null:
		var g := Gradient.new()
		g.offsets = PackedFloat32Array([0.0, 0.7, 1.0])
		g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
		var t := GradientTexture2D.new()
		t.gradient = g
		t.width = 48
		t.height = 128
		t.fill = GradientTexture2D.FILL_RADIAL
		t.fill_from = Vector2(0.5, 0.5)
		t.fill_to = Vector2(1.0, 0.5)
		_streak = t
	return _streak


static func _radial(offsets: PackedFloat32Array, colors: PackedColorArray) -> Texture2D:
	var g := Gradient.new()
	g.offsets = offsets
	g.colors = colors
	var t := GradientTexture2D.new()
	t.gradient = g
	t.width = 128
	t.height = 128
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	return t
