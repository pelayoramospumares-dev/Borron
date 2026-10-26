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


func test_missing_layer_uses_placeholder() -> void:
	var room := Room.new()
	room.room_id = &"test"
	add_child_autofree(room)
	var l := room.painted_layer("res://art/backgrounds/zone1/no_existe.png", 1500.0, Vector2(500, 900), false)
	assert_not_null(l)
	var spr := l.content().get_child(0) as Sprite2D
	assert_not_null(spr)
	assert_eq(spr.texture.get_width(), 64, "textura sustituta")


func test_optional_missing_layer_is_skipped() -> void:
	var room := Room.new()
	room.room_id = &"test"
	add_child_autofree(room)
	assert_null(room.painted_layer("res://art/backgrounds/zone1/no_existe.png", 1500.0, Vector2(500, 900)))


func test_existing_layer_loads_texture() -> void:
	var img := Image.create(32, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.5, 0.5, 0.5))
	var path := "user://test_layer.png"
	img.save_png(path)
	var room := Room.new()
	room.room_id = &"test"
	add_child_autofree(room)
	var l := room.painted_layer(path, 800.0, Vector2(0, 0))
	var spr := l.content().get_child(0) as Sprite2D
	assert_eq(spr.texture.get_width(), 32)
	DirAccess.remove_absolute(path)
