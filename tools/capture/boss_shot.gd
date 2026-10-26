extends Node2D
## Muestra al Escriba Hueco en reposo y preparando el Trazo. --out=/ruta/prefijo

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.6, 0.62, 0.67))
	add_child(GameEnvironment.create())
	var floor_body := StaticBody2D.new()
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(4000, 200)
	cs.shape = r
	floor_body.position = Vector2(960, 900)
	floor_body.add_child(cs)
	var fp := Polygon2D.new()
	fp.polygon = PackedVector2Array([Vector2(-2000, -100), Vector2(2000, -100), Vector2(2000, 100), Vector2(-2000, 100)])
	fp.color = Color(0.16, 0.16, 0.19)
	floor_body.add_child(fp)
	add_child(floor_body)
	var player: Player = load("res://player/player.tscn").instantiate()
	player.position = Vector2(700, 752)
	add_child(player)
	var boss: Scribe = load("res://bosses/scribe/scribe.tscn").instantiate()
	boss.position = Vector2(1150, 700)
	add_child(boss)
	var cam := Camera2D.new()
	cam.position = Vector2(960, 680)
	cam.zoom = Vector2(1.7, 1.7)
	add_child(cam)
	cam.make_current()
	var prefix := CaptureUtil.arg("out", "user://boss")
	for k in 30:
		await get_tree().physics_frame
	CaptureUtil.save(self, prefix + "_idle.png")
	boss.set(&"state", &"trazo")
	boss.set(&"_t", 0.0)
	for k in 40:
		await get_tree().physics_frame
	CaptureUtil.save(self, prefix + "_trazo.png")
	get_tree().quit()
