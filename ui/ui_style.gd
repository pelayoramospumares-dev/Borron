class_name UiStyle
## Estilo común de la interfaz: tinta oscura, texto pálido, sin píxeles.

const PALE := Color(0.86, 0.87, 0.92)
const DIM := Color(0.55, 0.56, 0.62)
const PANEL := Color(0.02, 0.02, 0.035, 0.88)
const ACCENT := Color(0.95, 0.82, 0.5)

static var _theme: Theme


static func font() -> Font:
	return ThemeDB.fallback_font


static func theme() -> Theme:
	if _theme:
		return _theme
	_theme = Theme.new()
	_theme.default_font_size = 26
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0, 0, 0, 0)
	normal.content_margin_left = 18
	normal.content_margin_right = 18
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var focus := normal.duplicate() as StyleBoxFlat
	focus.bg_color = Color(1, 1, 1, 0.06)
	focus.border_color = ACCENT
	focus.border_width_bottom = 2
	_theme.set_stylebox(&"normal", &"Button", normal)
	_theme.set_stylebox(&"hover", &"Button", focus)
	_theme.set_stylebox(&"focus", &"Button", focus)
	_theme.set_stylebox(&"pressed", &"Button", focus)
	_theme.set_stylebox(&"disabled", &"Button", normal)
	_theme.set_color(&"font_color", &"Button", DIM)
	_theme.set_color(&"font_hover_color", &"Button", PALE)
	_theme.set_color(&"font_focus_color", &"Button", PALE)
	_theme.set_color(&"font_pressed_color", &"Button", ACCENT)
	_theme.set_color(&"font_color", &"Label", PALE)
	_theme.set_color(&"font_outline_color", &"Label", Color(0, 0, 0, 0.8))
	_theme.set_constant(&"outline_size", &"Label", 6)
	return _theme


static func label(text: String, size: int = 26, color: Color = PALE) -> Label:
	var l := Label.new()
	l.text = text
	l.theme = theme()
	l.add_theme_font_size_override(&"font_size", size)
	l.add_theme_color_override(&"font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func button(text: String, size: int = 30) -> Button:
	var b := Button.new()
	b.text = text
	b.theme = theme()
	b.flat = false
	b.add_theme_font_size_override(&"font_size", size)
	b.focus_mode = Control.FOCUS_ALL
	return b


## Fondo oscuro a pantalla completa.
static func backdrop(alpha: float = 0.88) -> ColorRect:
	var r := ColorRect.new()
	r.color = Color(PANEL, alpha)
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	return r
