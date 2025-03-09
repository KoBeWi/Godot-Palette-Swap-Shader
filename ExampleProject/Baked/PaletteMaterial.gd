@tool
extends ShaderMaterial
class_name PaletteMaterial

@export var palette: Texture2D:
	set = set_palette

@export var animation_fps: int = 6:
	set(v):
		if v != animation_fps:
			animation_fps = v
			set_shader_parameter(&"fps", animation_fps)

func set_palette(pal: Texture2D):
	if palette == pal:
		return
	
	palette = pal
	var image := palette.get_image()
	
	var color_count := image.get_width()
	var frames := palette.get_height() - 1
	assert(color_count * frames <= 256)
	
	if frames == 1:
		shader = preload("res://Baked/SimplePaletteSwap.gdshader")
	else:
		shader = preload("res://Baked/AnimatedPaletteSwap.gdshader")
	
	var source: PackedInt32Array
	source.resize(768)
	
	var output: PackedVector3Array
	output.resize(256)
	
	for i in color_count:
		var color := image.get_pixel(i, 0)
		source[i * 3 + 0] = roundi(color.r * 255.0)
		source[i * 3 + 1] = roundi(color.g * 255.0)
		source[i * 3 + 2] = roundi(color.b * 255.0)
	
	for y in frames:
		for x in color_count:
			var color := image.get_pixel(x, y + 1)
			output[x + y * color_count] = Vector3(color.r, color.g, color.b)
	
	if frames > 1:
		set_shader_parameter(&"fps", animation_fps)
		set_shader_parameter(&"frame_count", frames)
	
	set_shader_parameter(&"color_count", color_count)
	set_shader_parameter(&"source", source)
	set_shader_parameter(&"output", output)

func _validate_property(property: Dictionary) -> void:
	if property["name"] == "shader":
		property["usage"] = PROPERTY_USAGE_NONE
