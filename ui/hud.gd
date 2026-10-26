class_name Hud
extends CanvasLayer
## HUD: vida como una gota que se vacía, medidor de tinta, anillo de
## Inestabilidad que late, contador de Recuerdos, barra de jefe y avisos.
## Todo se dibuja con código y se anima con suavizado (nada de saltos).

const ORIGIN := Vector2(110, 110)
const DROP_SIZE := 46.0
const INK_BAR := Rect2(175, 92, 260, 22)
const PALE := Color(0.86, 0.87, 0.92)
const INK := Color(0.03, 0.03, 0.05)
const GOLD := Color(2.0, 1.65, 0.85)
const RING_A := Color(0.65, 0.3, 1.0)
const RING_B := Color(1.0, 0.2, 0.35)

var _player: Player
var _canvas: Control
var _health := 1.0
var _ink := 0.0
var _instab := 0.0
var _overflow := 0.0
var _recuerdos_shown := 0.0
var _t := 0.0
var _boss: EnemyBase
var _boss_label: Label
var _boss_hp := 1.0
var _notice: Label
var _notice_sub: Label


func _ready() -> void:
	layer = 20
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_hud)
	add_child(_canvas)
	_boss_label = UiStyle.label("", 28)
	_boss_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_boss_label.position = Vector2(-300, -120)
	_boss_label.size = Vector2(600, 40)
	_boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_label.visible = false
	add_child(_boss_label)
	_notice = UiStyle.label("", 46)
	_notice.set_anchors_preset(Control.PRESET_CENTER)
	_notice.position = Vector2(-500, -140)
	_notice.size = Vector2(1000, 60)
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice.modulate.a = 0.0
	add_child(_notice)
	_notice_sub = UiStyle.label("", 24)
	_notice_sub.set_anchors_preset(Control.PRESET_CENTER)
	_notice_sub.position = Vector2(-500, -76)
	_notice_sub.size = Vector2(1000, 40)
	_notice_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice_sub.modulate.a = 0.0
	add_child(_notice_sub)
	EventBus.ability_unlocked.connect(_on_ability)
	_recuerdos_shown = GameState.recuerdos


func bind(p: Player) -> void:
	_player = p


func show_boss(boss: EnemyBase, title_key: String) -> void:
	_boss = boss
	_boss_hp = 1.0
	_boss_label.text = tr(title_key)
	_boss_label.visible = true


func hide_boss() -> void:
	_boss = null
	_boss_label.visible = false


func shown_health() -> float:
	return _health


func shown_ink() -> float:
	return _ink


func _process(delta: float) -> void:
	advance(delta)


func advance(delta: float) -> void:
	_t += delta
	if _player and is_instance_valid(_player) and _player.is_node_ready():
		var k := 1.0 - exp(-10.0 * delta)
		_health = lerpf(_health, _player.health.hp / _player.health.max_hp, k)
		_ink = lerpf(_ink, _player.ink.ink / _player.ink.config.max_ink, k)
		_instab = lerpf(_instab, _player.ink.instability / 100.0, k)
		var of := 1.0 if _player.ink.state == InkMeter.State.OVERFLOW else 0.0
		_overflow = lerpf(_overflow, of, k)
	_recuerdos_shown = move_toward(_recuerdos_shown, GameState.recuerdos, delta * 12.0)
	if _boss and is_instance_valid(_boss):
		_boss_hp = lerpf(_boss_hp, _boss.health.hp / _boss.health.max_hp, 1.0 - exp(-8.0 * delta))
	elif _boss_label.visible:
		hide_boss()
	if _canvas:
		_canvas.queue_redraw()


func _draw_hud() -> void:
	var c := _canvas
	# Anillo de Inestabilidad (late más rápido cuanto más alta).
	var pulse := 0.5 + 0.5 * sin(_t * lerpf(2.0, 14.0, _instab))
	var ring_col := RING_A.lerp(RING_B, _instab)
	ring_col.a = lerpf(0.25, 0.9, _instab) * lerpf(0.7, 1.0, pulse)
	var ring_hdr := 1.0 + _overflow * 1.6
	ring_col = Color(ring_col.r * ring_hdr, ring_col.g * ring_hdr, ring_col.b * ring_hdr, ring_col.a)
	c.draw_arc(ORIGIN, DROP_SIZE + 14, -PI * 0.5, -PI * 0.5 + TAU * _instab, 64, ring_col, 5.0 + _overflow * 3.0, true)
	c.draw_arc(ORIGIN, DROP_SIZE + 14, 0, TAU, 64, Color(1, 1, 1, 0.08), 2.0, true)
	# Gota de vida: contorno de tinta y líquido pálido que baja con el daño.
	var drop := _drop_polygon(ORIGIN, DROP_SIZE)
	c.draw_colored_polygon(drop, INK)
	var top := ORIGIN.y + DROP_SIZE * 1.0 - (DROP_SIZE * 2.3) * _health
	var wave := PackedVector2Array()
	var left := ORIGIN.x - DROP_SIZE * 1.2
	var right := ORIGIN.x + DROP_SIZE * 1.2
	for i in 17:
		var x := lerpf(left, right, i / 16.0)
		wave.append(Vector2(x, top + sin(_t * 3.0 + i * 0.7) * 2.5))
	wave.append(Vector2(right, ORIGIN.y + DROP_SIZE * 2))
	wave.append(Vector2(left, ORIGIN.y + DROP_SIZE * 2))
	for poly in Geometry2D.intersect_polygons(drop, wave):
		c.draw_colored_polygon(poly, PALE)
	drop.append(drop[0])
	c.draw_polyline(drop, Color(0.0, 0.0, 0.0, 0.9), 3.0, true)
	# Medidor de tinta: trazo de pincel con marca del coste de curación.
	var bar := INK_BAR
	c.draw_rect(bar.grow(3), Color(0, 0, 0, 0.45))
	var fill := Rect2(bar.position, Vector2(bar.size.x * _ink, bar.size.y))
	c.draw_rect(fill, Color(0.06, 0.06, 0.09))
	if _ink > 0.01:
		c.draw_line(Vector2(fill.end.x, bar.position.y), Vector2(fill.end.x, bar.end.y), PALE * Color(1, 1, 1, 0.6), 2.0)
	for k in 3:
		var mx := bar.position.x + bar.size.x * 0.33 * (k + 1)
		c.draw_line(Vector2(mx, bar.position.y - 4), Vector2(mx, bar.end.y + 4), Color(1, 1, 1, 0.35), 2.0)
	# Recuerdos.
	var rp := Vector2(196, 148)
	c.draw_colored_polygon(PackedVector2Array([rp + Vector2(0, -12), rp + Vector2(9, 0), rp + Vector2(0, 12), rp + Vector2(-9, 0)]), GOLD)
	c.draw_string(UiStyle.font(), rp + Vector2(18, 10), str(roundi(_recuerdos_shown)), HORIZONTAL_ALIGNMENT_LEFT, -1, 28, PALE)
	# Barra del jefe.
	if _boss_label.visible:
		var vs := c.size
		var br := Rect2(vs.x * 0.5 - 400, vs.y - 74, 800, 14)
		c.draw_rect(br.grow(3), Color(0, 0, 0, 0.6))
		c.draw_rect(Rect2(br.position, Vector2(br.size.x * _boss_hp, br.size.y)), Color(0.75, 0.74, 0.8))


func _drop_polygon(center: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 25:
		var a := lerpf(-0.75, PI + 0.75, i / 24.0)
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	pts.append(center + Vector2(0, -r * 1.75))
	return pts


func _on_ability(id: StringName) -> void:
	var key := "ABILITY_%s" % String(id).to_upper()
	_notice.text = "%s: %s" % [tr("ABILITY_GAINED"), tr(key)]
	_notice_sub.text = tr(key + "_HINT")
	var tw := create_tween()
	tw.tween_property(_notice, ^"modulate:a", 1.0, 0.6)
	tw.parallel().tween_property(_notice_sub, ^"modulate:a", 1.0, 0.6)
	tw.tween_interval(3.5)
	tw.tween_property(_notice, ^"modulate:a", 0.0, 1.0)
	tw.parallel().tween_property(_notice_sub, ^"modulate:a", 0.0, 1.0)
