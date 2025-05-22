shader_type spatial;
render_mode unshaded;

#include "cel_shade.gdshaderinc"

uniform sampler2D GRAYSCALE_TEXTURE : repeat_disable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

void vertex(){
	POSITION = vec4(VERTEX.xy, 1., 1.);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec3 screen_color = texture(SCREEN_TEXTURE, uv).rgb;
	ALBEDO = cel_shade(screen_color, GRAYSCALE_TEXTURE);
}