shader_type spatial;
render_mode unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

uniform float line_highlight = .2;
uniform float line_shadow = .55;

float normal_edge_indicator(vec3 normal_edge_bias, vec3 normal, vec3 neighbor_normal, float depth_difference) {
	// https://threejs.org/examples/webgl_postprocessing_pixel.html
	float normal_difference = dot(normal - neighbor_normal, normal_edge_bias);
	float normal_indicator = clamp(smoothstep(-.01, .01, normal_difference), 0., 1.);
	float depth_indicator = clamp(sign(depth_difference * .25 + .0025), 0., 1.);
	return (1. - dot(normal, neighbor_normal)) * depth_indicator * normal_indicator;
}

// Converts normals from 0:1 to -1:1.
vec3 get_normal(vec2 uv, sampler2D normal_texture) {
	vec3 normal = texture(normal_texture, uv).rgb;
	normal = normal * 2. - 1.;
	return normal;
}

float get_linear_depth(vec2 sUV, sampler2D depth_texture, mat4 inv_projection_mat) {
	float depth = texture(depth_texture, sUV).x;
	vec3 ndc = vec3(sUV * 2. - 1., depth);
	vec4 view = inv_projection_mat * vec4(ndc, 1.);
	view.xyz /= view.w;
	return -view.z;
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1., 1.);
}

void fragment() {
	vec2 texel_size = 1. / VIEWPORT_SIZE.xy;
	
	vec2 UV_offsets[4];
	UV_offsets[0] = SCREEN_UV + vec2(0., -1.) * texel_size;
	UV_offsets[1] = SCREEN_UV + vec2(0., 1.) * texel_size;
	UV_offsets[2] = SCREEN_UV + vec2(1., 0.) * texel_size;
	UV_offsets[3] = SCREEN_UV + vec2(-1., 0.) * texel_size;
	
	float depth_difference = 0.;
	float inv_depth_difference = .5;
	float depth = get_linear_depth(SCREEN_UV, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
	
	for (int i = 0; i < UV_offsets.length(); i++) {
		float depth_offset = get_linear_depth(UV_offsets[i], DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		depth_difference += clamp(depth_offset - depth, 0., 1.);
		inv_depth_difference += depth - depth_offset;
	}
	
	inv_depth_difference = clamp(inv_depth_difference, 0., 1.);
	// Multiply by 10 to sharpen the values.
	inv_depth_difference = clamp(smoothstep(.9, .9, inv_depth_difference) * 10., 0., 1.);
	depth_difference = smoothstep(.25, .3, depth_difference);
	
	float normal_difference = 0.;
	vec3 normal_edge_bias = vec3(1.);
	vec3 normal = get_normal(SCREEN_UV, NORMAL_TEXTURE);
	for (int i = 0; i < UV_offsets.length(); i++) {
		vec3 normal_offset = get_normal(UV_offsets[i], NORMAL_TEXTURE);
		normal_difference += normal_edge_indicator(normal_edge_bias, normal, normal_offset, depth_difference);
	}
	
	normal_difference = smoothstep(.2, .2, normal_difference);
	normal_difference = clamp(normal_difference - inv_depth_difference, 0., 1.);
	float final_edge = clamp(normal_difference + depth_difference, 0., 1.);
	
	float innerLines = clamp(normal_difference - depth_difference, 0., 1.);
	ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	ALBEDO += innerLines * line_highlight;
	ALBEDO -= ALBEDO * depth_difference * line_shadow;
}
