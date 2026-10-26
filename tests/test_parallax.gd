extends GutTest


func test_parallax_factors() -> void:
	assert_almost_eq(DepthLayer.parallax_factor(0.0), 1.0, 0.0001)
	assert_almost_eq(DepthLayer.parallax_factor(1000.0), 0.5, 0.0001)
	assert_almost_eq(DepthLayer.parallax_factor(-200.0), 1.25, 0.0001)


func test_position_follows_perspective() -> void:
	var layer := DepthLayer.new()
	layer.depth = 1000.0
	layer.anchor = Vector2(500, 300)
	# Con la cámara centrada en el ancla, el elemento está en su sitio.
	assert_eq(layer.position_for_camera(Vector2(500, 300)), Vector2(500, 300))
	# Si la cámara se mueve 200 px, un elemento a profundidad 1000 se mueve la mitad en pantalla.
	var p := layer.position_for_camera(Vector2(700, 300))
	assert_almost_eq(p.x - 700.0, (500.0 - 700.0) * 0.5, 0.001)
	layer.free()


func test_fog_increases_with_depth() -> void:
	assert_eq(DepthLayer.fog_amount(0.0), 0.0)
	assert_gt(DepthLayer.fog_amount(3000.0), DepthLayer.fog_amount(1000.0))
	assert_almost_eq(DepthLayer.fog_amount(100000.0), 0.85, 0.0001)


func test_foreground_darkened() -> void:
	var near := DepthLayer.new()
	near.depth = -200.0
	add_child_autofree(near)
	var mid := DepthLayer.new()
	mid.depth = 0.0
	add_child_autofree(mid)
	assert_lt(near.darkness(), 1.0)
	assert_eq(mid.darkness(), 1.0)


func test_content_children_inherit_fog() -> void:
	var l := DepthLayer.new()
	l.depth = 2000.0
	add_child_autofree(l)
	var p := Polygon2D.new()
	l.content().add_child(p)
	assert_true(p.use_parent_material)
	assert_true(l.content().use_parent_material)
