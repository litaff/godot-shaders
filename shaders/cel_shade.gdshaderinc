float gray_scale(vec3 color) {
	return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
}

vec3 cel_shade(vec3 color, sampler2D grayscale_texture) {
	float gray_scale_screen_color = gray_scale(color);
	vec4 cel_color = texture(grayscale_texture, vec2(gray_scale_screen_color, 0.0));
	return cel_color.r * color.rgb;
}

vec3 cel_shade(vec3 color, sampler2D grayscale_texture, float sample) {
	vec4 cel_color = texture(grayscale_texture, vec2(sample, 0.0));
	return cel_color.r * color.rgb;
}
