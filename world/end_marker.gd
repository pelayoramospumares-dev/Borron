class_name EndMarker
extends Area2D
## Marca el final del prototipo tras vencer al jefe.

var _shown: bool = false


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(200, 300)
	cs.shape = r
	cs.position = Vector2(0, -150)
	add_child(cs)
	EnemyBody.poly(self, [Vector2(-30, 0), Vector2(30, 0), Vector2(20, -220), Vector2(0, -260), Vector2(-20, -220)],
			Color(0.06, 0.06, 0.08))
	body_entered.connect(func(b: Node) -> void:
		if b is Player and GameState.bosses_defeated.has(&"scribe") and not _shown:
			_shown = true
			_show_message())


func _show_message() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 40
	var label := Label.new()
	label.text = tr("END_PROTOTYPE")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.add_theme_font_size_override(&"font_size", 44)
	label.modulate.a = 0.0
	layer.add_child(label)
	add_child(layer)
	var tw := label.create_tween()
	tw.tween_property(label, ^"modulate:a", 1.0, 1.5)
