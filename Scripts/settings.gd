extends Node2D

@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SfxSlider


func _ready() -> void:
	music_slider.value = AudioSettings.music_volume * 100.0
	sfx_slider.value = AudioSettings.sfx_volume * 100.0

	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)


func _on_music_changed(value: float) -> void:
	AudioSettings.set_music_volume(value / 100.0)


func _on_sfx_changed(value: float) -> void:
	AudioSettings.set_sfx_volume(value / 100.0)
