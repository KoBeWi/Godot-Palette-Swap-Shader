@tool
extends EditorScript

func _run() -> void:
	var selection := get_editor_interface().get_selection().get_selected_nodes()
	assert(not selection.is_empty(), "Select some nodes to generate texture.")
	
	for node in selection:
		var texture := node.get("texture") as Texture2D
		if texture:
			generate_palette_from(texture.get_image(), texture.resource_path)
			return
	
	assert(false, "No selected node has 'texture' property with a valid Texture.")

func generate_palette_from(image: Image, texture_path: String):
	print("Generating palette for: ", texture_path)
	
	var colors: PackedColorArray
	
	for x in image.get_width():
		for y in image.get_height():
			var color := image.get_pixel(x, y)
			if color.a > 0:
				color = Color(color, 1.0)
				if not color in colors:
					colors.append(color)
	
	var palette := Image.create(colors.size(), 2, false, Image.FORMAT_RGB8)
	
	for i in colors.size():
		palette.set_pixel(i, 0, colors[i])
		palette.set_pixel(i, 1, Color.BLACK)
	
	var png_path := "%s/%s_palette.png" % [texture_path.get_base_dir(), texture_path.get_file().get_basename()]
	palette.save_png(png_path)
	get_editor_interface().get_resource_filesystem().scan()
	
	print("Generated: ", png_path)
