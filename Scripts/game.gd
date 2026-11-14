extends Node2D

var menu_scene = "res://Scenes/MainScenes/menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var error = get_tree().change_scene_to_file(menu_scene)
		if error != OK:
			print("Failed to change scene, error code: ", error)
