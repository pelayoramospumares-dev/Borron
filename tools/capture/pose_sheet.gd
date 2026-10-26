extends Node2D
## Hoja con todas las poses del cuerpo de tinta. Uso:
## xvfb-run godot --path . --rendering-driver opengl3 res://tools/capture/pose_sheet.tscn -- --out=/ruta.png

const COLS := 7
const CELL := Vector2(270, 270)
const SCALE := 2.4


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.62, 0.64, 0.68))
	CaptureUtil.add_glow(self)
	var poses := PoseLibrary.POSES.keys()
	var i := 0
	for pose: StringName in poses:
		var cell := Vector2(i % COLS, i / COLS)
		var origin := cell * CELL + Vector2(CELL.x * 0.5, CELL.y * 0.62)
		var holder := Node2D.new()
		holder.position = origin
		holder.scale = Vector2.ONE * SCALE
		add_child(holder)
		var body := InkBody.new()
		holder.add_child(body)
		body.snap_to_pose(pose)
		if pose == &"puddle":
			for k in 120:
				body.advance(1.0 / 120.0)
		var label := Label.new()
		label.text = String(pose)
		label.position = origin + Vector2(-130, 80)
		label.add_theme_color_override(&"font_color", Color(0.1, 0.1, 0.12))
		add_child(label)
		i += 1
	# Variante con Inestabilidad alta y Desborde.
	var hot := Node2D.new()
	hot.position = Vector2(i % COLS, i / COLS) * CELL + Vector2(CELL.x * 0.5, CELL.y * 0.62)
	hot.scale = Vector2.ONE * SCALE
	add_child(hot)
	var hb := InkBody.new()
	hot.add_child(hb)
	hb.snap_to_pose(&"idle")
	hb.set_instability(100)
	hb.set(&"_overflow_target", 1.0)
	for k in 60:
		hb.advance(1.0 / 60.0)
	await get_tree().process_frame
	for k in 30:
		await get_tree().process_frame
	CaptureUtil.save(self, CaptureUtil.arg("out", "user://pose_sheet.png"))
	get_tree().quit()
