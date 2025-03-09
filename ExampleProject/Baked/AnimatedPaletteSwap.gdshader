shader_type canvas_item;

uniform int color_count;
uniform ivec3[256] source;
uniform vec3[256] output;

uniform float fps;
uniform int frame_count;

void fragment() {
	ivec3 colori = ivec3(round(COLOR.rgb * 255.0));
	for (int i = 0; i < color_count; i++) {
		if (colori == source[i]) {
			i += int(TIME * fps) % frame_count * color_count;
			COLOR.rgb = output[i];
			break;
		}
	}
}