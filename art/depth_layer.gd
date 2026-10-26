class_name DepthLayer
extends Node2D
## Elemento de escenario a una profundidad (técnica de Hollow Knight en 2D).
## depth 0 = plano de juego; > 0 detrás; < 0 delante del jugador.
## Se desplaza con la fórmula de perspectiva factor = F / (F + depth) y se
## tiñe de niebla según la distancia. Los hijos heredan el material.

const FOCAL := 1000.0
const FOG_DISTANCE := 3000.0
const MAX_FOG := 0.85
const FOG_SHADER := preload("res://art/depth_fog.gdshader")
const BLUR_SHADER := preload("res://art/depth_blur.gdshader")

@export var depth: float = 0.0
@export var fog_color: Color = Color(0.6, 0.62, 0.66)
## Posición en el mundo cuando la cámara está centrada en ella (por defecto, su posición inicial).
var anchor: Vector2 = Vector2.INF

var _content: Node2D


static func parallax_factor(d: float) -> float:
	return FOCAL / (FOCAL + d)


static func fog_amount(d: float) -> float:
	return clampf(d / FOG_DISTANCE, 0.0, MAX_FOG)


func darkness() -> float:
	return 0.15 if depth < 0.0 else 1.0


func position_for_camera(camera_center: Vector2) -> Vector2:
	return camera_center + (anchor - camera_center) * parallax_factor(depth)


func _ready() -> void:
	if anchor == Vector2.INF:
		anchor = position
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	# Se dibuja después de que la cámara haya actualizado la vista.
	process_priority = 100
	z_index = clampi(-int(depth / 10.0), -4000, 4000)
	var mat := ShaderMaterial.new()
	mat.shader = FOG_SHADER
	mat.set_shader_parameter(&"fog_color", fog_color)
	mat.set_shader_parameter(&"fog_amount", fog_amount(depth))
	mat.set_shader_parameter(&"darkness", darkness())
	material = mat
	for c in get_children():
		_inherit(c)
	child_entered_tree.connect(_inherit)


## Contenedor donde añadir los dibujos. En primer plano añade desenfoque.
func content() -> Node2D:
	if _content == null:
		if depth < 0.0:
			var g := CanvasGroup.new()
			g.use_mipmaps = true
			g.fit_margin = 24.0
			var mat := ShaderMaterial.new()
			mat.shader = BLUR_SHADER
			g.material = mat
			_content = g
		else:
			_content = Node2D.new()
			_content.child_entered_tree.connect(_inherit)
		add_child(_content)
	return _content


func _inherit(n: Node) -> void:
	if n is CanvasGroup:
		(n as CanvasGroup).modulate = Color(darkness(), darkness(), darkness() * 1.1)
		return
	var ci := n as CanvasItem
	if ci:
		ci.use_parent_material = true
		# Las luces del plano de juego no iluminan el fondo lejano.
		if depth > 150.0:
			ci.light_mask = 0
	for c in n.get_children():
		_inherit(c)


func _process(_delta: float) -> void:
	var vp := get_viewport()
	if vp == null:
		return
	var center := vp.get_canvas_transform().affine_inverse() * (vp.get_visible_rect().size * 0.5)
	position = position_for_camera(center)
