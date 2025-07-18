extends Control

@export var image_file_path: String

func _ready():
	gen_image()

func gen_image():
	await get_tree().process_frame
	await get_tree().process_frame
	
	var grect := get_global_rect()
	var factor := get_tree().root.get_stretch_transform().get_scale()
	var rect := Rect2(grect.position*factor, grect.size*factor)
	
	var image = get_viewport().get_texture().get_image().get_region(rect);
	image.save_png(image_file_path);
