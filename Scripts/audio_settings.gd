extends Node

const SAVE_FILE := "settings.cfg"
const SAVE_DELAY := 0.25

var music_volume: float = 0.7
var sfx_volume: float = 0.8

var _save_timer: Timer


func _ready() -> void:
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = SAVE_DELAY
	_save_timer.timeout.connect(_save_settings)
	add_child(_save_timer)

	_load_settings()
	_apply_all()


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_bus("Music", music_volume)
	_save_timer.start()


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_bus("SFX", sfx_volume)
	_save_timer.start()


func _apply_all() -> void:
	_apply_bus("Music", music_volume)
	_apply_bus("SFX", sfx_volume)


func _apply_bus(bus_name: String, value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index == -1:
		push_warning("Audio bus '%s' not found" % bus_name)
		return
	AudioServer.set_bus_mute(index, value <= 0.001)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.001)))


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SavePaths.file(SAVE_FILE)) != OK:
		return
	music_volume = clampf(float(config.get_value("audio", "music", music_volume)), 0.0, 1.0)
	sfx_volume = clampf(float(config.get_value("audio", "sfx", sfx_volume)), 0.0, 1.0)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.save(SavePaths.file(SAVE_FILE))
