extends Node2D
## Sala de pruebas: suelo de x=-2000 a x=0 con top en y=0, pared en x=-1500..-1460 alta,
## y una plataforma aislada a la derecha (x=300..2300) a y=0 separada por un hueco.

func _ready() -> void:
	_box(Rect2(-2000, 0, 2000, 200))        # suelo izquierdo
	_box(Rect2(-1500, -1200, 40, 1200))     # pared
	_box(Rect2(300, 0, 2000, 200))          # suelo derecho


func _box(r: Rect2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = r.size
	shape.shape = rect
	body.position = r.get_center()
	body.add_child(shape)
	add_child(body)
	return body


## Rejilla (capa grates) en x=-600, de y=-300 a y=0.
func add_grate() -> StaticBody2D:
	var g := _box(Rect2(-610, -300, 20, 300))
	g.collision_layer = 32
	return g


## Túnel bajo: techo de x=-1300 a x=-1100 cuya base queda a 40 px del suelo.
func add_low_tunnel() -> StaticBody2D:
	return _box(Rect2(-1300, -400, 200, 360))
