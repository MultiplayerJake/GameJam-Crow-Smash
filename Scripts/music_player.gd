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

	var dir := DirAccess.open(MUSIC_DIR)
	if dir == null:
		return null

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension().to_lower() in AUDIO_EXTENSIONS:
			var path := "%s/%s" % [MUSIC_DIR, file_name]
			dir.list_dir_end()
			return load(path)
		file_name = dir.get_next()
	dir.list_dir_end()
	return null


func _enable_loop() -> void:
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
