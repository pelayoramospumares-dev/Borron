extends Room
## r10 · Arena del Escriba Hueco. Fin del prototipo.

const ScribeScene := preload("res://bosses/scribe/scribe.tscn")


func _init() -> void:
	room_id = &"r10"
	bounds = Rect2(0, 0, 2880, 1080)
	sky_top = Color(0.52, 0.52, 0.58)
	sky_bottom = Color(0.3, 0.3, 0.35)


func _build() -> void:
	solid(Rect2(-200, 900, 3300, 500))
	solid(Rect2(2680, -200, 400, 1500))
	entry(&"left", Vector2(220, 852))
	transition(Rect2(-90, 500, 100, 400), &"r09", &"right")
	var arena := BossArena.new()
	arena.boss_id = &"scribe"
	arena.boss_scene = ScribeScene
	arena.boss_spawn = Vector2(2200, 790)
	arena.trigger_rect = Rect2(800, 300, 300, 600)
	arena.door_rects = [Rect2(560, 200, 40, 700)] as Array[Rect2]
	add_actor(arena)
	var end := EndMarker.new()
	end.position = Vector2(2500, 900)
	add_actor(end)
	for x: float in [900.0, 1500.0, 2100.0]:
		column(x, 900, rng.randf_range(400, 900), rng.randf_range(450, 700))
	far_skyline(780, 5200.0)
	foreground_brush(1200, 900, 300)
	painted_backdrop(900)
