shader_type canvas_item;

uniform int color_count;
uniform ivec3[256] source;
uniform vec3[256] output;

void fragment() {
	ivec3 colori = ivec3(round(COLOR.rgb * 255.0));
	for (int i = 0; i < color_count; i++) {
		if (colori == source[i]) {
			COLOR.rgb = output[i];
			break;
		}
	}
}