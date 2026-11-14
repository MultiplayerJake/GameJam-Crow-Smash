extends AudioStreamPlayer

const MUSIC_DIR := "res://Assets/Music"
const AUDIO_EXTENSIONS := ["ogg", "wav", "mp3"]


func _ready() -> void:
	if stream == null:
		stream = _find_track()
	if stream == null:
		return
	_enable_loop()
	play()


func _find_track() -> AudioStream:
	for extension in AUDIO_EXTENSIONS:
		var path := "%s/theme.%s" % [MUSIC_DIR, extension]
		if ResourceLoader.exists(path):
			return load(path)

	var files := ResourceLoader.list_directory(MUSIC_DIR)
	if files.is_empty():
		var dir := DirAccess.open(MUSIC_DIR)
		if dir == null:
			return null
		files = PackedStringArray(dir.get_files())

	for entry in files:
		var file_name := entry.get_file().trim_suffix(".import").trim_suffix(".remap")
		if file_name.get_extension().to_lower() in AUDIO_EXTENSIONS:
			return load(MUSIC_DIR.path_join(file_name))
	return null


func _enable_loop() -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
