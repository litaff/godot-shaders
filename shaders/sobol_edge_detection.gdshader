shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;

uniform float edge_threshold = 0.2;
uniform vec3 line_color: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 sobel = vec3(1.0, 2.0, 1.0);

void vertex(){
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	mat3 sobel_y = mat3(
		vec3(sobel.x, 0.0, -sobel.x),
		vec3(sobel.y, 0.0, -sobel.y),
		vec3(sobel.z, 0.0, -sobel.z)
	);

	mat3 sobel_x = mat3(
		vec3(sobel.x, sobel.y, sobel.z),
		vec3(0.0, 0.0, 0.0),
		vec3(-sobel.x, -sobel.y, -sobel.z)
	);

	vec2 uv = SCREEN_UV;
	vec4 screen_color = texture(SCREEN_TEXTURE, uv);
	vec3 normal = texture(NORMAL_TEXTURE, uv).rgb;
	normal = normal * 2.0 - 1.0;
	vec2 offset = 0.8 / VIEWPORT_SIZE;

	vec3 n = texture(NORMAL_TEXTURE, uv + vec2(0.0, -offset.y)).rgb;
	vec3 s = texture(NORMAL_TEXTURE, uv + vec2(0.0, offset.y)).rgb;
	vec3 e = texture(NORMAL_TEXTURE, uv + vec2(offset.x, 0.0)).rgb;
	vec3 w = texture(NORMAL_TEXTURE, uv + vec2(-offset.x, 0.0)).rgb;
	vec3 nw = texture(NORMAL_TEXTURE, uv + vec2(-offset.x, -offset.y)).rgb;
	vec3 ne = texture(NORMAL_TEXTURE, uv + vec2(offset.x, -offset.y)).rgb;
	vec3 sw = texture(NORMAL_TEXTURE, uv + vec2(-offset.x, offset.y)).rgb;
	vec3 se = texture(NORMAL_TEXTURE, uv + vec2(offset.x, offset.y)).rgb;

	mat3 surrounding_pixels = mat3(
		vec3(length(nw-normal), length(n-normal), length(ne-normal)),
		vec3(length(w-normal), length(normal-normal), length(e-normal)),
		vec3(length(sw-normal), length(s-normal), length(se-normal))
	);

	float edge_x = dot(sobel_x[0], surrounding_pixels[0]) + dot(sobel_x[1], surrounding_pixels[1]) + dot(sobel_x[2], surrounding_pixels[2]);
	float edge_y = dot(sobel_y[0], surrounding_pixels[0]) + dot(sobel_y[1], surrounding_pixels[1]) + dot(sobel_y[2], surrounding_pixels[2]);

	float edge = sqrt(pow(edge_x, 2.0)+pow(edge_y, 2.0));

	if (edge > edge_threshold) {
		ALBEDO = line_color;
		ALPHA = edge;
	} else {
		ALPHA = 0.0;
	}
}