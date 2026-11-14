extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the button's pressed signal to our quit function
	pressed.connect(_on_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	# Quits the game application
	get_tree().quit()
