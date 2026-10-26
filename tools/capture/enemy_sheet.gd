extends Node2D
## Muestra los tres enemigos animándose. --out=/ruta.png

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.6, 0.62, 0.67))
	add_child(GameEnvironment.create())
	var floor_body := StaticBody2D.new()
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(4000, 200)
	cs.shape = r
	floor_body.position = Vector2(960, 800)
	floor_body.add_child(cs)
	var fp := Polygon2D.new()
	fp.polygon = PackedVector2Array([Vector2(-2000, -100), Vector2(2000, -100), Vector2(2000, 100), Vector2(-2000, 100)])
	fp.color = Color(0.16, 0.16, 0.19)
	floor_body.add_child(fp)
	add_child(floor_body)
	var scenes := ["res://enemies/crawler/crawler.tscn", "res://enemies/flyer/flyer.tscn", "res://enemies/spitter/spitter.tscn"]
	var xs := [800.0, 960.0, 1120.0]
	for i in 3:
		var holder := Node2D.new()
		add_child(holder)
		var e: Node2D = load(scenes[i]).instantiate()
		e.position = Vector2(xs[i], 600 if i == 1 else 660)
		holder.add_child(e)
	var cam := Camera2D.new()
	cam.position = Vector2(960, 600)
	cam.zoom = Vector2(2.6, 2.6)
	cam.position = Vector2(960, 640)
	add_child(cam)
	cam.make_current()
	for k in 50:
		await get_tree().physics_frame
	CaptureUtil.save(self, CaptureUtil.arg("out", "user://enemies.png"))
	get_tree().quit()
