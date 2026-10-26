// Niebla atmosférica por profundidad: mezcla el color hacia el de la niebla
// y oscurece los elementos que están por delante del jugador.
shader_type canvas_item;

uniform vec4 fog_color : source_color = vec4(0.6, 0.62, 0.66, 1.0);
uniform float fog_amount = 0.0;
uniform float darkness = 1.0;

void fragment() {
	vec4 c = COLOR;
	c.rgb = mix(c.rgb * darkness, fog_color.rgb, fog_amount);
	COLOR = c;
}
