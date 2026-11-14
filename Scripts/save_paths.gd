extends Node

const SAVE_DIR := "user://Saves"
var dir: String


func _init() -> void:
	dir = ProjectSettings.globalize_path(SAVE_DIR)
	DirAccess.make_dir_recursive_absolute(dir)


func file(file_name: String) -> String:
	return dir.path_join(file_name)
