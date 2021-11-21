tool
extends EditorScript

const IMPORT_OPTIONS = """[deps]
source_file="%s"
[params]
flags/filter=false
"""

func _run() -> void:
	var selection := get_editor_interface().get_selection().get_selected_nodes()
	assert(not selection.empty(), "Select some nodes to generate texture.")
	
	for node in selection:
		var texture := node.get("texture") as Texture
		if texture:
			generate_palette_from(texture.get_data(), texture.resource_path)
			return
	
	assert(false, "No selected node has 'texture' property with a valid Texture.")

func generate_palette_from(image: Image, texture_path: String):
	print("Generating palette for: ", texture_path)
	
	var colors := []
	image.lock()
	
	for x in image.get_width():
		for y in image.get_height():
			var color = image.get_pixel(x, y)
			if color.a > 0:
				color = Color(color.r, color.g, color.b)
				if not color in colors:
					colors.append(color)
	image.unlock()
	
	var palette := Image.new()
	palette.create(colors.size(), 2, false, Image.FORMAT_RGB8)
	palette.lock()
	
	for i in colors.size():
		palette.set_pixel(i, 0, colors[i])
		palette.set_pixel(i, 1, Color.black)
	
	palette.unlock()
	
	var png_path := str(texture_path.get_base_dir(), "/", texture_path.get_file().get_basename(), "_palette.png")
	var file := File.new()
	file.open(png_path + ".import", file.WRITE)
	file.store_string(IMPORT_OPTIONS % png_path)
	file.close()
	
	palette.save_png(png_path)
	get_editor_interface().get_resource_filesystem().scan()
	
	print("Generated: ", png_path)
