extends Node2D
## Captura en movimiento: el jugador corre, salta y golpea una diana.
## Guarda varias imágenes: --out=/ruta/prefijo  (genera prefijo_N.png)

const PlayerScene := preload("res://player/player.tscn")

var player: Player


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.55, 0.58, 0.64))
	add_child(GameEnvironment.create())
	_box(Rect2(-2000, 0, 6000, 400), Color(0.16, 0.16, 0.19))
	_box(Rect2(700, -500, 80, 500), Color(0.16, 0.16, 0.19))
	player = PlayerScene.instantiate()
	player.position = Vector2(0, -48)
	add_child(player)
	var cam := GameCamera.new()
	cam.zoom = Vector2(1.6, 1.6)
	add_child(cam)
	cam.make_current()
	cam.target = player
	var vfx := VfxSpawner.new()
	vfx.camera = cam
	add_child(vfx)
	await get_tree().process_frame
	vfx.bind_player(player)
	cam.snap_to_target()
	var dummy := Node2D.new()
	dummy.position = Vector2(420, -60)
	add_child(dummy)
	var hb := Hurtbox.new()
	hb.collision_layer = 0
	hb.collision_mask = 8
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(60, 120)
	cs.shape = r
	hb.add_child(cs)
	dummy.add_child(hb)
	hb.owner = dummy
	var dpoly := Polygon2D.new()
	dpoly.polygon = PackedVector2Array([Vector2(-30, 60), Vector2(30, 60), Vector2(20, -60), Vector2(-20, -60)])
	dpoly.color = Color(0.3, 0.28, 0.3)
	dummy.add_child(dpoly)

	var prefix := CaptureUtil.arg("out", "user://action")
	player.ink.ink = 80
	Input.action_press("move_right")
	await _frames(40)
	CaptureUtil.save(self, prefix + "_1_run.png")
	Input.action_press("jump")
	await _frames(14)
	CaptureUtil.save(self, prefix + "_2_jump.png")
	Input.action_release("jump")
	await _frames(30)
	Input.action_release("move_right")
	Input.action_press("attack")
	await _frames(9)
	CaptureUtil.save(self, prefix + "_3_slash.png")
	Input.action_release("attack")
	await _frames(4)
	CaptureUtil.save(self, prefix + "_4_splash.png")
	player.ink.ink = 100
	player.ink.instability = 99.5
	await _frames(20)
	CaptureUtil.save(self, prefix + "_5_overflow.png")
	Input.action_press("dash")
	await _frames(8)
	CaptureUtil.save(self, prefix + "_6_dash.png")
	get_tree().quit()


func _frames(n: int) -> void:
	for i in n:
		await get_tree().physics_frame


func _box(rect: Rect2, color: Color) -> void:
	var b := StaticBody2D.new()
	var cs := CollisionShape2D.new()
	var s := RectangleShape2D.new()
	s.size = rect.size
	cs.shape = s
	b.position = rect.get_center()
	b.add_child(cs)
	var poly := Polygon2D.new()
	var h := rect.size * 0.5
	poly.polygon = PackedVector2Array([-h, Vector2(h.x, -h.y), h, Vector2(-h.x, h.y)])
	poly.color = color
	b.add_child(poly)
	add_child(b)
