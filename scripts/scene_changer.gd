extends Node

@export var scene: PackedScene

func _change_scene():
	get_tree().change_scene_to_packed(scene)

func _reload_current_scene():
	get_tree().reload_current_scene()
