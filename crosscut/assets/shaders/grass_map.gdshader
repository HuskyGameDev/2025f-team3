shader_type spatial;
render_mode unshaded;

uniform sampler2D grass_texture : repeat_enable, filter_linear_mipmap;
uniform float tile_scale : hint_range(1.0, 50.0) = 10.0;
uniform float noise_strength : hint_range(0.0, 20.0) = 10.0;
uniform float noise_scale : hint_range(0.1, 20.0) = 10.0;

vec2 hash(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(dot(hash(i), f), dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
		mix(dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
			dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x),
		u.y
	);
}

void fragment() {
	// Tile the UVs
	vec2 uv = UV * tile_scale;

	// Add noise distortion to break up the repeating pattern
	float n = noise(UV * noise_scale);
	uv += n * noise_strength;

	vec3 grass = texture(grass_texture, uv).rgb;
	
	ALBEDO = grass;
}
