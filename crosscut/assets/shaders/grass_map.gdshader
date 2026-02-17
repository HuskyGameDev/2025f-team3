shader_type spatial;
render_mode unshaded;

uniform sampler2D grass_texture : repeat_enable, filter_linear_mipmap;
uniform float tile_scale : hint_range(1.0, 50.0) = 10.0;
uniform float noise_strength : hint_range(0.0, 20.0) = 10.0;
uniform float noise_scale : hint_range(0.1, 20.0) = 10.0;

// Grid outline matching tower placement grid
uniform float grid_cell_size : hint_range(0.5, 20.0) = 5.0;   // match GridMap cell_size.x
uniform float map_size : hint_range(10.0, 500.0) = 100.0;      // match PlaneMesh size
uniform float grid_opacity : hint_range(0.0, 1.0) = 0.5;
uniform float line_width : hint_range(0.01, 2.0) = 0.1;         // world units (meters)
uniform vec4 grid_color : source_color = vec4(0.1, 0.15, 0.05, 1.0);

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

	// Grid outline aligned to tower placement grid.
	// UV 0..1 spans world -map_size/2 .. +map_size/2, centered at origin.
	vec2 world_xz = (UV - 0.5) * map_size;
	// fract gives 0..1 position within each cell; +0.5 centers squares on snap points
	// Multiply by grid_cell_size to get distance in world units (meters)
	vec2 cell_pos = fract(world_xz / grid_cell_size + 0.5) * grid_cell_size;
	// Distance from nearest edge in world units (0 at edge, grid_cell_size/2 at center)
	vec2 edge = min(cell_pos, grid_cell_size - cell_pos);
	// On an edge if either axis is within line_width of the cell border
	float is_edge = max(step(edge.x, line_width), step(edge.y, line_width));

	ALBEDO = mix(grass, grid_color.rgb, is_edge * grid_opacity);
}
