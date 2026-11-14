extends Node

const SAVE_DIR := "res://Saves"
const SAVE_PATH := "res://Saves/skins.save"

var owned_bats: Array[int] = [1]
var owned_crows: Array[int] = [1]
var equipped_bat: int = 1
var equipped_crow: int = 1


func load_skins() -> void:
	owned_bats = [1]
	owned_crows = [1]
	equipped_bat = 1
	equipped_crow = 1

	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
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


func save_skins() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SAVE_DIR))
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open %s for writing" % SAVE_PATH)
		return

	file.store_line("BAT: " + _format_skin_list(owned_bats))
	file.store_line("CROW: " + _format_skin_list(owned_crows))
	file.store_line("EQ-BAT: " + str(equipped_bat))
	file.store_line("EQ-CROW: " + str(equipped_crow))


func add_owned_skin(kind: String, number: int) -> void:
	if kind == "bat":
		if not owned_bats.has(number):
			owned_bats.append(number)
			owned_bats.sort()
	elif kind == "crow":
		if not owned_crows.has(number):
			owned_crows.append(number)
			owned_crows.sort()
	else:
		push_warning("Unknown skin kind: %s" % kind)
		return
	save_skins()


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
