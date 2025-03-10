## Recolors CanvasItem based on a palette.
##
## PaletteMaterial allows to recolor sprites and other 2D nodes by using a palette. It also supports animation. To use it, assign [member palette] and the material will automatically assign itself a shader (which can't be changed).
## [br][br][b]Note:[/b] The material will automatically set shader parameters, do not modify them.
@tool
class_name PaletteMaterial extends ShaderMaterial

## The palette used for recoloring. The top row of the palette are reference colors, the lower rows are target colors. If there is only [code]2[/code] rows, the material will swap the top colors with bottom colors when matched. If there is more rows, the material will cycle the target rows.
## [br][br] For performance reasons, the palette only supports up to [code]256[/code] reference colors. Also it supports only [code]256[/code] target colors, even with animation, so number of columns multiplied by rows can't exceed [code]256[/code].
@export var palette: Texture2D:
	set = set_palette

## Affects how fast color cycling runs. Only has effect if [member palette] has more than [code]2[/code] rows.
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
	assert(color_count <= 256)
	var frames := palette.get_height() - 1
	assert(color_count * frames <= 256)
	
	if frames == 1:
		shader = preload("uid://6qkrex88eend")
	else:
		shader = preload("uid://cvvuo7gdy75iw")
	
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
