class_name CaptureUtil
## Utilidades para generar capturas de revisión (xvfb + opengl3).

static func arg(name: String, default: String = "") -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--%s=" % name):
			return a.split("=", true, 1)[1]
	return default


static func save(node: Node, path: String) -> void:
	var img := node.get_viewport().get_texture().get_image()
	img.save_png(path)
	print("captura: ", path)


static func add_glow(parent: Node) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.9
	env.glow_bloom = 0.05
	env.glow_hdr_threshold = 1.0
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	var we := WorldEnvironment.new()
	we.environment = env
	parent.add_child(we)
