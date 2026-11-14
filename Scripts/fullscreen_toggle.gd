extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggled.connect(_toggled)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		print("Turned fullscreen windowed mode on")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif toggled_on == false:
		print("Turned fullscreen windowed mode off")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		print("Error")
