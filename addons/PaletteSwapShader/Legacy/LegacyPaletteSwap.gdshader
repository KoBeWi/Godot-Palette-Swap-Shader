shader_type canvas_item;

/**
 * This is the palette image used for the texture.[br]To generate a palette image for a texture, go to Project -> Tools -> Generate Palette...
 */
uniform sampler2D palette : filter_nearest, repeat_disable;

/**
 * If [code]true[/code], the first row of colors is ignored and thus not used on the texture.
 */
uniform bool skip_first_row = true;

/**
 * If [code]true[/code], the texture uses the palette alpha. Otherwise, it uses the original texture's alpha.
 */
uniform bool use_palette_alpha = false;

/**
 * How many palette rows are cycled through each second.[br][br]If set to [code]0[/code], the colors do not cycle. If less than [code]0[/code], the colors cycle backwards.
 */
uniform float fps = 6;

/**
 * Specifies what row of colors the texture should use.[br][br]Only effective if [param fps] is [code]0[/code] and ignores [param skip_first_row].
 */
uniform int row = 0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	ivec3 colori = ivec3(round(original_color.rgb * 255.0));
	
	ivec2 color_count = textureSize(palette, 0);
	
	float idx = -1.0;
	for (int i = 0; i < color_count.x; i++) {
		vec3 color2 = texture(palette, vec2(float(i) / float(color_count.x - 1), 0)).rgb;
		ivec3 colori2 = ivec3(round(color2 * 255.0));
		
		if (colori == colori2) {
			idx = float(i);
			break;
		}
	}
	
	if (idx >= 0.0) {
		vec2 uv;
		uv.x = idx / float(color_count.x - 1);
		if (fps != 0.0) {
			uv.y = (mod(TIME * fps, max(float(color_count.y - 1 - int(skip_first_row)), 1.0)) + float(skip_first_row))  / float(color_count.y - 1);
		} else {
			uv.y = float(row) / float(color_count.y - 1);
		}
		
		vec4 palette_color = texture(palette, uv);
		COLOR = vec4(palette_color.rgb, mix(original_color.a, palette_color.a, float(use_palette_alpha)));
	} else {
		COLOR = original_color;
	}
}
