extends Node

const SAVE_FILE := "skins.save"

const KIND_BAT := "bat"
const KIND_CROW := "crow"

const BAT_DIRS := ["res://Assets/AssetsFin/character/bat", "res://Assets/AssetsFin/bat"]
const CROW_DIRS := ["res://Assets/AssetsFin/character/crow"]
const BAT_PREFIX := "batSkin"
const CROW_PREFIX := "crowSkin"

var owned_bats: Array[int] = [0]
var owned_crows: Array[int] = [0]
var equipped_bat: int = 0
var equipped_crow: int = 0

var skin_textures: Dictionary = {
	KIND_BAT: {},
	KIND_CROW: {},
}

var _catalog_ready := false


func _ready() -> void:
	_build_catalog()


func _build_catalog() -> void:
	if _catalog_ready:
		return
	_catalog_ready = true
	for dir_path in BAT_DIRS:
		_scan_skins(dir_path, BAT_PREFIX, KIND_BAT)
	for dir_path in CROW_DIRS:
		_scan_skins(dir_path, CROW_PREFIX, KIND_CROW)
	if not skin_textures[KIND_BAT].has(0):
		push_warning("No %s skin 0 found" % KIND_BAT)
	if not skin_textures[KIND_CROW].has(0):
		push_warning("No %s skin 0 found" % KIND_CROW)


func _scan_skins(dir_path: String, prefix: String, kind: String) -> void:
	var files := ResourceLoader.list_directory(dir_path)
	if files.is_empty():
		var dir := DirAccess.open(dir_path)
		if dir == null:
			push_warning("Skin folder missing: %s" % dir_path)
			return
		files = PackedStringArray(dir.get_files())
	for entry in files:
		var file_name := entry.get_file().trim_suffix(".import").trim_suffix(".remap")
		if not file_name.begins_with(prefix) or not file_name.ends_with(".png"):
			continue
		var number_text := file_name.trim_prefix(prefix).get_basename()
		if not number_text.is_valid_int():
			continue
		skin_textures[kind][int(number_text)] = load(dir_path.path_join(file_name))


func load_skins() -> void:
	_build_catalog()

	owned_bats = [0]
	owned_crows = [0]
	equipped_bat = 0
	equipped_crow = 0

	if not FileAccess.file_exists(SavePaths.file(SAVE_FILE)):
		save_skins()
		return
	var file := FileAccess.open(SavePaths.file(SAVE_FILE), FileAccess.READ)
	if file == null:
		return

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue
		var separator := line.find(":")
		if separator == -1:
			continue
		var key := line.substr(0, separator).strip_edges()
		var value := line.substr(separator + 1).strip_edges()
		match key:
			"BAT":
				owned_bats = _parse_skin_list(value)
			"CROW":
				owned_crows = _parse_skin_list(value)
			"EQ-BAT":
				if value.is_valid_int():
					equipped_bat = int(value)
			"EQ-CROW":
				if value.is_valid_int():
					equipped_crow = int(value)

	if not owned_bats.has(0):
		owned_bats.append(0)
		owned_bats.sort()
	if not owned_crows.has(0):
		owned_crows.append(0)
		owned_crows.sort()
	if not owned_bats.has(equipped_bat):
		equipped_bat = 0
	if not owned_crows.has(equipped_crow):
		equipped_crow = 0
	if not has_skin(KIND_BAT, equipped_bat):
		equipped_bat = 0
	if not has_skin(KIND_CROW, equipped_crow):
		equipped_crow = 0


func save_skins() -> void:
	var path := SavePaths.file(SAVE_FILE)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open %s for writing" % path)
		return

	file.store_line("BAT: " + _format_skin_list(owned_bats))
	file.store_line("CROW: " + _format_skin_list(owned_crows))
	file.store_line("EQ-BAT: " + str(equipped_bat))
	file.store_line("EQ-CROW: " + str(equipped_crow))


func add_owned_skin(kind: String, number: int) -> void:
	if kind == KIND_BAT:
		if not owned_bats.has(number):
			owned_bats.append(number)
			owned_bats.sort()
	elif kind == KIND_CROW:
		if not owned_crows.has(number):
			owned_crows.append(number)
			owned_crows.sort()
	else:
		push_warning("Unknown skin kind: %s" % kind)
		return
	save_skins()


func is_owned(kind: String, number: int) -> bool:
	if kind == KIND_BAT:
		return owned_bats.has(number)
	elif kind == KIND_CROW:
		return owned_crows.has(number)
	return false


func is_equipped(kind: String, number: int) -> bool:
	if kind == KIND_BAT:
		return equipped_bat == number
	elif kind == KIND_CROW:
		return equipped_crow == number
	return false


func has_skin(kind: String, number: int) -> bool:
	var textures: Dictionary = skin_textures.get(kind, {})
	return textures.has(number)


func get_texture(kind: String, number: int) -> Texture2D:
	var textures: Dictionary = skin_textures.get(kind, {})
	if textures.is_empty():
		return null
	if textures.has(number):
		return textures[number] as Texture2D
	return textures.get(0) as Texture2D


func equip_skin(kind: String, number: int) -> bool:
	if not is_owned(kind, number):
		return false
	var target := number
	if not has_skin(kind, number):
		target = 0
	if kind == KIND_BAT:
		equipped_bat = target
	elif kind == KIND_CROW:
		equipped_crow = target
	else:
		return false
	save_skins()
	return true


#This function takes a comma-separated list of numbers written as text and turns it into a clean list of actual numbers.
#It automatically ignores any extra spaces and throws away anything that isn't a valid number.
func _parse_skin_list(value: String) -> Array[int]:
	var result: Array[int] = []
	for part in value.split(",", false):
		var entry := part.strip_edges()
		if entry.is_valid_int():
			result.append(int(entry))
	return result


func _format_skin_list(numbers: Array[int]) -> String:
	var parts := PackedStringArray()
	for number in numbers:
		parts.append(str(number))
	return ", ".join(parts)
