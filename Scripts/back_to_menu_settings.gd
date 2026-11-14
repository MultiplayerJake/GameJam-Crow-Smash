extends Button

var menu_scene = "res://Scenes/MainScenes/menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	var error = get_tree().change_scene_to_file(menu_scene)
	print("changed the scene to Menu scene")
	if error != OK:
		print("Failed to change scene, error code: ", error)
