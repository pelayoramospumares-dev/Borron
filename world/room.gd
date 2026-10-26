class_name Room
extends Node2D
## Sala del mundo. Cada sala concreta (world/zone1/rXX.gd) describe su
## contenido en _build() con las funciones de abajo: suelos, plataformas,
## enemigos, Tinteros, Recuerdos, transiciones y escenario en profundidad.

const CrawlerScene := preload("res://enemies/crawler/crawler.tscn")
const FlyerScene := preload("res://enemies/flyer/flyer.tscn")
const SpitterScene := preload("res://enemies/spitter/spitter.tscn")
const ShrineScene := preload("res://world/ability_shrine.tscn")
const GrateScene := preload("res://world/grate.tscn")

## Paleta de la Zona 1 (spec §5.2): grises fríos y niebla.
const GROUND := Color(0.11, 0.11, 0.13)
const GROUND_RIM := Color(0.26, 0.27, 0.31)
const SCENERY := Color(0.16, 0.16, 0.19)
const FOREGROUND := Color(0.02, 0.02, 0.03)
## Los elementos del fondo se prolongan hacia abajo para no "flotar" con la perspectiva.
const BASE := 900.0

@export var room_id: StringName
@export var bounds: Rect2 = Rect2(0, 0, 1920, 1080)
@export var sky_top: Color = Color(0.66, 0.68, 0.72)
@export var sky_bottom: Color = Color(0.43, 0.44, 0.49)
@export var fog_color: Color = Color(0.62, 0.64, 0.68)

var rng := RandomNumberGenerator.new()
var _entries: Dictionary = {}
var _geometry: Node2D
var _actors: Node2D


func _ready() -> void:
	rng.seed = hash(String(room_id))
	_geometry = Node2D.new()
	_geometry.name = "Geometry"
	add_child(_geometry)
	_actors = Node2D.new()
	_actors.name = "Actors"
	add_child(_actors)
	_build()
	_frame_void()
	_ambient()


## Las salas concretas sobrescriben esto.
func _build() -> void:
	pass


# --- Consultas -------------------------------------------------------------------

func get_entry(entry_id: StringName) -> Vector2:
	return _entries.get(entry_id, bounds.get_center())


func has_entry(entry_id: StringName) -> bool:
	return _entries.has(entry_id)


func entry_names() -> Array[StringName]:
	var out: Array[StringName] = []
	for k: StringName in _entries:
		out.append(k)
	return out


func transitions() -> Array[RoomTransition]:
	var out: Array[RoomTransition] = []
	for c in _actors.get_children():
		if c is RoomTransition:
			out.append(c)
	return out


func recuerdos() -> Array[Recuerdo]:
	var out: Array[Recuerdo] = []
	for c in _actors.get_children():
		if c is Recuerdo and not c.is_queued_for_deletion():
			out.append(c)
	return out


func tintero() -> Tintero:
	for c in _actors.get_children():
		if c is Tintero:
			return c
	return null


func add_actor(n: Node2D) -> void:
	_actors.add_child(n)


# --- Construcción ------------------------------------------------------------------

## Bloque sólido. El dibujo tiene bordes irregulares; la colisión es exacta.
func solid(r: Rect2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = r.size
	cs.shape = shape
	body.position = r.get_center()
	body.add_child(cs)
	_geometry.add_child(body)
	var poly := Polygon2D.new()
	poly.polygon = _organic_rect(Rect2(-r.size * 0.5, r.size), 3.0)
	poly.color = GROUND
	poly.antialiased = true
	body.add_child(poly)
	# Borde superior más claro para leer bien dónde se pisa.
	var rim := Line2D.new()
	var h := r.size * 0.5
	var pts := PackedVector2Array()
	var steps := maxi(2, int(r.size.x / 40.0))
	for i in steps + 1:
		var x := lerpf(-h.x + 2, h.x - 2, float(i) / steps)
		pts.append(Vector2(x, -h.y + 1.5 + rng.randf_range(-1.2, 1.2)))
	rim.points = pts
	rim.width = 3.0
	rim.default_color = GROUND_RIM
	rim.antialiased = true
	body.add_child(rim)
	return body


## Plataforma atravesable desde abajo.
func platform(x: float, y: float, width: float) -> StaticBody2D:
	var body := solid(Rect2(x, y, width, 24))
	var cs := body.get_child(0) as CollisionShape2D
	cs.one_way_collision = true
	return body


func entry(entry_id: StringName, pos: Vector2) -> void:
	_entries[entry_id] = pos


func transition(r: Rect2, target_room: StringName, target_entry: StringName) -> RoomTransition:
	var t := RoomTransition.new()
	t.rect = r
	t.target_room = target_room
	t.target_entry = target_entry
	_actors.add_child(t)
	return t


func enemy(kind: StringName, pos: Vector2) -> EnemyBase:
	var scene: PackedScene
	match kind:
		&"crawler":
			scene = CrawlerScene
		&"flyer":
			scene = FlyerScene
		&"spitter":
			scene = SpitterScene
	var e: EnemyBase = scene.instantiate()
	e.position = pos
	_actors.add_child(e)
	return e


func recuerdo(local_id: String, pos: Vector2, value: int = 1) -> Recuerdo:
	var r := Recuerdo.new()
	r.pickup_id = StringName("%s_%s" % [room_id, local_id])
	r.value = value
	r.position = pos
	_actors.add_child(r)
	return r


func tintero_at(x: float, floor_y: float) -> Tintero:
	var t := Tintero.new()
	t.room_id = room_id
	t.position = Vector2(x, floor_y)
	_actors.add_child(t)
	entry(&"tintero", Vector2(x - 70, floor_y - Player.HALF_HEIGHT))
	return t


func grate(x: float, floor_y: float, height: float = 200.0) -> Node2D:
	var g: Node2D = GrateScene.instantiate()
	g.position = Vector2(x, floor_y)
	g.scale.y = height / 200.0
	_actors.add_child(g)
	return g


## Rejilla horizontal sobre un hueco del suelo (solo pasa el charco).
func floor_grate(x: float, y: float, width: float) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 32
	body.collision_mask = 0
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, 24)
	cs.shape = shape
	body.position = Vector2(x + width * 0.5, y + 12)
	body.add_child(cs)
	var n := int(width / 18.0)
	for i in n + 1:
		var bx := -width * 0.5 + i * width / n
		_poly(body, [Vector2(bx - 3, -12), Vector2(bx + 3, -12), Vector2(bx + 3, 12), Vector2(bx - 3, 12)], GROUND_RIM.darkened(0.3))
	_poly(body, [Vector2(-width * 0.5, -12), Vector2(width * 0.5, -12), Vector2(width * 0.5, -7), Vector2(-width * 0.5, -7)], GROUND_RIM.darkened(0.3))
	_geometry.add_child(body)
	return body


func shrine(ability: StringName, x: float, floor_y: float) -> AbilityShrine:
	var s: AbilityShrine = ShrineScene.instantiate()
	s.ability_id = ability
	s.position = Vector2(x, floor_y)
	_actors.add_child(s)
	return s


# --- Escenario en profundidad ---------------------------------------------------------

func layer(depth: float, pos: Vector2) -> DepthLayer:
	var l := DepthLayer.new()
	l.depth = depth
	l.fog_color = fog_color
	l.position = pos
	add_child(l)
	return l


## Fondo pintado (p. ej. generado con Higgsfield) a una profundidad.
## `pos` es el centro inferior de la imagen; `width` el ancho con el que se
## muestra (0 = tamaño original). Si falta la imagen: con optional se omite
## (queda el escenario procedural); si no, se muestra un sustituto rosa.
func painted_layer(path: String, depth: float, pos: Vector2, optional: bool = true, width: float = 0.0) -> DepthLayer:
	var tex := _load_texture(path)
	if tex == null:
		if optional:
			return null
		push_warning("Room: falta la imagen %s; se usa un sustituto" % path)
		tex = _placeholder_texture()
	var l := layer(depth, pos)
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.centered = true
	var sc := width / tex.get_width() if width > 0.0 else 1.0
	spr.scale = Vector2(sc, sc)
	spr.position = Vector2(0, -tex.get_height() * sc * 0.5)
	l.content().add_child(spr)
	return l


## Las tres capas pintadas de una sala (lejana, media, cercana), si existen:
## art/backgrounds/zone1/<sala>_far.png, _mid.png y _near.png.
func painted_backdrop(ground_y: float) -> void:
	var view_w := 1920.0 * 1.25
	for info: Array in [["far", 4000.0], ["mid", 1500.0], ["near", 400.0]]:
		var depth: float = info[1]
		var f := DepthLayer.parallax_factor(depth)
		var width := view_w + maxf(bounds.size.x - view_w, 0.0) * f + 400.0
		var path := "res://art/backgrounds/zone1/%s_%s.png" % [room_id, info[0]]
		painted_layer(path, depth, Vector2(bounds.get_center().x, ground_y + 60.0), true, width)


func _load_texture(path: String) -> Texture2D:
	if path.begins_with("res://") and ResourceLoader.exists(path):
		return load(path) as Texture2D
	if FileAccess.file_exists(path):
		var img := Image.load_from_file(path)
		if img:
			return ImageTexture.create_from_image(img)
	return null


func _placeholder_texture() -> Texture2D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.0, 0.8))
	return ImageTexture.create_from_image(img)


## Casa en ruinas a medio borrar.
func ruined_house(x: float, ground_y: float, depth: float, w: float, h: float) -> void:
	var l := layer(depth, Vector2(x, ground_y))
	var pts := [Vector2(-w * 0.5, BASE), Vector2(-w * 0.5, -h), Vector2(-w * 0.1, -h - w * 0.45),
			Vector2(w * 0.15, -h - w * 0.3), Vector2(w * 0.2, -h - w * 0.4), Vector2(w * 0.5, -h)]
	# Esquina "borrada".
	var bite := rng.randf_range(0.2, 0.5)
	pts.append(Vector2(w * 0.5, -h * bite))
	pts.append(Vector2(w * 0.32, -h * (bite - 0.12)))
	pts.append(Vector2(w * 0.5, BASE))
	_poly(l.content(), pts, SCENERY)
	# Ventanas vacías.
	for i in rng.randi_range(1, 3):
		var wx := rng.randf_range(-w * 0.35, w * 0.2)
		var wy := rng.randf_range(-h * 0.85, -h * 0.4)
		_poly(l.content(), [Vector2(wx, wy), Vector2(wx + 18, wy), Vector2(wx + 18, wy + 26), Vector2(wx, wy + 26)],
				fog_color.darkened(0.25))


func column(x: float, ground_y: float, depth: float, h: float, broken: bool = true) -> void:
	var l := layer(depth, Vector2(x, ground_y))
	var top := -h
	var pts := [Vector2(-22, BASE), Vector2(-18, top + 20), Vector2(-26, top + 6), Vector2(-26, top)]
	if broken:
		pts += [Vector2(-8, top - 14), Vector2(4, top + 4), Vector2(14, top - 22), Vector2(26, top)]
	else:
		pts += [Vector2(26, top)]
	pts += [Vector2(26, top + 6), Vector2(18, top + 20), Vector2(22, BASE)]
	_poly(l.content(), pts, SCENERY)


func dead_tree(x: float, ground_y: float, depth: float, h: float) -> void:
	var l := layer(depth, Vector2(x, ground_y))
	_poly(l.content(), [Vector2(-6, 0), Vector2(6, 0), Vector2(8, BASE), Vector2(-8, BASE)], SCENERY)
	_branch(l.content(), Vector2.ZERO, -PI * 0.5 + rng.randf_range(-0.1, 0.1), h * 0.45, 12.0, 4)


func lantern_post(x: float, ground_y: float, depth: float) -> void:
	var l := layer(depth, Vector2(x, ground_y))
	_poly(l.content(), [Vector2(-4, BASE), Vector2(4, BASE), Vector2(3, -180), Vector2(-3, -180)], SCENERY)
	_poly(l.content(), [Vector2(-3, -180), Vector2(26, -196), Vector2(28, -190), Vector2(3, -172)], SCENERY)
	_poly(l.content(), [Vector2(16, -190), Vector2(34, -190), Vector2(38, -170), Vector2(30, -150),
			Vector2(20, -150), Vector2(12, -170)], SCENERY)


func hanging_chain(x: float, top_y: float, depth: float, length: float) -> void:
	var l := layer(depth, Vector2(x, top_y))
	var line := Line2D.new()
	line.points = PackedVector2Array([Vector2.ZERO, Vector2(rng.randf_range(-6, 6), length)])
	line.width = 4.0
	line.default_color = SCENERY
	l.content().add_child(line)
	_poly(l.content(), _ellipse(Vector2(0, length + 10), Vector2(10, 14)), SCENERY)


## Matas y ramas oscuras delante del jugador.
func foreground_brush(x: float, ground_y: float, width: float) -> void:
	var l := layer(-220.0, Vector2(x, ground_y + 30))
	var pts: Array = [Vector2(-width * 0.5, 80)]
	var n := int(width / 22.0)
	for i in n + 1:
		var px := lerpf(-width * 0.5, width * 0.5, float(i) / n)
		var tall := rng.randf_range(20, 110) * sin(PI * float(i) / n)
		pts.append(Vector2(px - 6, -tall * 0.3))
		pts.append(Vector2(px, -tall))
	pts.append(Vector2(width * 0.5, 80))
	_poly(l.content(), pts, FOREGROUND)


## Silueta de colinas/tejados muy al fondo.
func far_skyline(y: float, depth: float) -> void:
	var l := layer(depth, Vector2(bounds.get_center().x, y))
	var w := bounds.size.x * 2.0 + 2400.0
	var pts: Array = [Vector2(-w * 0.5, 900)]
	var x := -w * 0.5
	while x < w * 0.5:
		var hh := rng.randf_range(80, 260)
		pts.append(Vector2(x, -hh))
		x += rng.randf_range(60, 180)
		if rng.randf() < 0.3:
			pts.append(Vector2(x - 30, -hh - rng.randf_range(40, 90)))
		pts.append(Vector2(x, -hh))
	pts.append(Vector2(w * 0.5, 900))
	_poly(l.content(), pts, SCENERY)


## Decoración estándar de las Afueras Borradas a lo largo de un suelo.
func decorate_outskirts(ground_y: float, from_x: float, to_x: float) -> void:
	far_skyline(ground_y - 120, 5200.0)
	var x := from_x
	while x < to_x:
		ruined_house(x, ground_y, rng.randf_range(1600, 2600), rng.randf_range(160, 280), rng.randf_range(160, 320))
		x += rng.randf_range(380, 640)
	x = from_x + rng.randf_range(0, 300)
	while x < to_x:
		var roll := rng.randf()
		if roll < 0.45:
			column(x, ground_y, rng.randf_range(350, 900), rng.randf_range(220, 520))
		elif roll < 0.75:
			dead_tree(x, ground_y, rng.randf_range(300, 900), rng.randf_range(260, 460))
		else:
			lantern_post(x, ground_y, rng.randf_range(200, 500))
		x += rng.randf_range(300, 560)
	x = from_x + rng.randf_range(100, 500)
	while x < to_x:
		foreground_brush(x, ground_y, rng.randf_range(120, 260))
		x += rng.randf_range(700, 1300)


# --- Interno --------------------------------------------------------------------

func _frame_void() -> void:
	# Relleno oscuro alrededor de los límites (se ve en pantallas no 16:9).
	var m := 2000.0
	var b := bounds
	for r: Rect2 in [Rect2(b.position.x - m, b.position.y - m, b.size.x + 2 * m, m),
			Rect2(b.position.x - m, b.end.y, b.size.x + 2 * m, m),
			Rect2(b.position.x - m, b.position.y, m, b.size.y),
			Rect2(b.end.x, b.position.y, m, b.size.y)]:
		var p := Polygon2D.new()
		p.polygon = PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
		p.color = Color(0.03, 0.03, 0.04)
		p.z_index = 10
		add_child(p)


func _ambient() -> void:
	var ash := InkParticles.create(&"ambient_ash")
	var m := ash.process_material as ParticleProcessMaterial
	m.emission_box_extents = Vector3(bounds.size.x * 0.5, bounds.size.y * 0.5, 0)
	ash.amount = int(clampf(bounds.get_area() / 30000.0, 40, 220))
	ash.position = bounds.get_center()
	ash.visibility_rect = Rect2(-bounds.size, bounds.size * 2.0)
	ash.z_index = 5
	add_child(ash)
	ash.emitting = true


func _poly(parent: Node, pts: Array, color: Color) -> Polygon2D:
	var p := Polygon2D.new()
	p.polygon = PackedVector2Array(pts)
	p.color = color
	p.antialiased = true
	parent.add_child(p)
	return p


func _ellipse(c: Vector2, r: Vector2) -> Array:
	return EnemyBody.ellipse(c, r, 14)


func _branch(parent: Node, from: Vector2, angle: float, length: float, width: float, depth_left: int) -> void:
	var dir := Vector2.from_angle(angle)
	var to := from + dir * length
	var n := dir.orthogonal() * width * 0.5
	var n2 := dir.orthogonal() * width * 0.32
	_poly(parent, [from + n, to + n2, to - n2, from - n], SCENERY)
	if depth_left <= 0:
		return
	for s: float in [-1.0, 1.0]:
		if rng.randf() < 0.85:
			_branch(parent, to, angle + s * rng.randf_range(0.3, 0.7), length * rng.randf_range(0.55, 0.75),
					width * 0.62, depth_left - 1)


## Rectángulo con bordes ligeramente irregulares (aspecto pintado, no de tiles).
func _organic_rect(r: Rect2, jitter: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var corners := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	for i in 4:
		var a: Vector2 = corners[i]
		var b: Vector2 = corners[(i + 1) % 4]
		var steps := maxi(1, int(a.distance_to(b) / 36.0))
		for k in steps:
			var p := a.lerp(b, float(k) / steps)
			if k > 0:
				var normal := (b - a).normalized().orthogonal()
				p += normal * rng.randf_range(-jitter, jitter)
			pts.append(p)
	return pts
