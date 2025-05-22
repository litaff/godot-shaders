shader_type spatial;

uniform float intensity = 2.0;
uniform float bias = 0.5;

void fragment() {
	vec3 normal = normalize(NORMAL);
	float curvature = abs(dot(normal, vec3(0.0, 0.0, 1.0)));
	
	float cavity_effect = pow(1.0 - curvature, intensity);
	cavity_effect = smoothstep(bias, 1.0, cavity_effect);
	
	vec3 base_color = ALBEDO;
	vec3 final_color = mix(base_color, vec3(0.0), cavity_effect);
	
	ALBEDO = final_color;
}
