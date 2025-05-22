shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D GRAYSCALE_TEXTURE : repeat_disable;

void vertex(){

}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_color = texture(SCREEN_TEXTURE, uv);
	float gray_scale_screen_color = 0.299 * screen_color.r + 0.587 * screen_color.g + 0.114 * screen_color.b;
	vec4 cel_color = texture(GRAYSCALE_TEXTURE, vec2(gray_scale_screen_color, 0.0));
	ALBEDO = cel_color.r * screen_color.rgb;
}