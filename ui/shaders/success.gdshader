shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 vignette_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float vignette_width : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	vec2 uv = SCREEN_UV * 2.0 - 1.0;
	float dist = length(uv);
	float edge_start = 1.0 - vignette_width;

	float vignette = smoothstep(edge_start, 1.0, dist);

	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);

	color.rgb = mix(color.rgb, vignette_color.rgb, vignette * vignette_intensity * vignette_color.a);
	COLOR = color;
}
