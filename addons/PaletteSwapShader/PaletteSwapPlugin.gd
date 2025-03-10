@tool
extends EditorPlugin

var image_filters: PackedStringArray

var palette: Image

func _enter_tree() -> void:
	add_tool_menu_item("Generate Palette...", generate_palette)
	
	var extensions: Array = ResourceLoader.get_recognized_extensions_for_type("Image")
	extensions = extensions.map(func(ext: String) -> String: return "*." + ext)
	image_filters.append(",".join(extensions) + ";Image File")

func _exit_tree() -> void:
	remove_tool_menu_item("Generate Palette...")

func generate_palette():
	DisplayServer.file_dialog_show("Select Image", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, image_filters, base_image_selected)

func base_image_selected(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
	if not status:
		return
	
	var image_path := selected_paths[0]
	var source_image := Image.load_from_file(image_path)
	if not source_image:
		push_error("Selected image is invalid.")
	
	palette = generate_palette_from(source_image)
	
	DisplayServer.file_dialog_show("Select Target Palette File", image_path.get_base_dir(), image_path.get_file().get_basename() + "_palette", false, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, ["*.webp;Palette File"], palette_image_selected)

func palette_image_selected(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
	var save_palette := palette
	palette = null
	
	if not status:
		return
	
	var save_path := selected_paths[0] + ".webp"
	save_palette.save_webp(save_path)
	
	EditorInterface.get_resource_filesystem().update_file(save_path)
	EditorInterface.get_resource_filesystem().reimport_files([save_path])

func generate_palette_from(image: Image) -> Image:
	var colors: PackedColorArray
	
	for x in image.get_width():
		for y in image.get_height():
			var color := image.get_pixel(x, y)
			if color.a > 0:
				color = Color(color, 1.0)
				if not color in colors:
					colors.append(color)
	
	var palette := Image.create(colors.size(), 2, false, Image.FORMAT_RGB8)
	palette.fill(Color.BLACK)
	
	for i in colors.size():
		palette.set_pixel(i, 0, colors[i])
	
	return palette
