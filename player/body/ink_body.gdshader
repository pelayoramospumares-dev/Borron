// Silueta de tinta (para CanvasGroup): borde ondulante, brillo húmedo y
// borde luminoso en Desborde. Lee la silueta ya fusionada del grupo.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float wobble_amount = 1.5;      // píxeles de ondulación del borde
uniform float wobble_speed = 2.2;
uniform float wobble_scale = 0.045;     // frecuencia espacial del ruido
uniform vec4 ink_color : source_color = vec4(0.025, 0.025, 0.04, 1.0);
uniform vec4 wet_color : source_color = vec4(0.55, 0.6, 0.75, 1.0);
uniform float wet_strength = 0.55;
uniform float overflow = 0.0;           // 0..1
uniform vec4 overflow_inner : source_color = vec4(0.55, 0.15, 0.95, 1.0);
uniform vec4 overflow_outer : source_color = vec4(0.95, 0.1, 0.25, 1.0);
uniform float overflow_hdr = 2.6;       // >1 para que brille con el glow
uniform float flash = 0.0;              // destello blanco al recibir daño

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float alpha_at(vec2 uv) {
	return textureLod(screen_texture, uv, 0.0).a;
}

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE;
	vec2 frag = SCREEN_UV / px;
	float t = TIME * wobble_speed;
	vec2 offset = vec2(noise(frag * wobble_scale + vec2(t, 0.0)),
			noise(frag * wobble_scale + vec2(0.0, t + 17.0))) * 2.0 - 1.0;
	vec2 uv = SCREEN_UV + offset * wobble_amount * px;
	vec4 c = textureLod(screen_texture, uv, 0.0);
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	float a = smoothstep(0.35, 0.65, c.a);

	// Distancia aproximada al borde: muestras en anillo.
	float r = 3.0 + overflow * 3.0;
	float edge = 0.0;
	for (int i = 0; i < 8; i++) {
		float ang = float(i) * 0.785398;
		edge += 1.0 - alpha_at(uv + vec2(cos(ang), sin(ang)) * r * px);
	}
	edge = clamp(edge / 4.0, 0.0, 1.0);

	// Brillo húmedo: borde superior (arriba transparente, aquí opaco).
	float above = 1.0 - alpha_at(uv + vec2(-1.0, -3.0) * px);
	float wet = above * edge * wet_strength;

	// Conserva el color propio de los detalles (ojos) y tiñe lo negro de tinta.
	float is_detail = step(0.2, max(c.r, max(c.g, c.b)));
	vec3 col = mix(ink_color.rgb, c.rgb, is_detail);
	col += wet_color.rgb * wet * (1.0 - is_detail);

	vec3 rim = mix(overflow_inner.rgb, overflow_outer.rgb, edge) * overflow_hdr;
	col = mix(col, rim, edge * overflow * (1.0 - is_detail));
	col = mix(col, vec3(1.0), flash);

	COLOR = vec4(col, a * COLOR.a);
}
