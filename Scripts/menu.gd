extends Node2D

var equipped_bat: int = 0
var equipped_crow: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SkinData.load_skins()
	equipped_bat = SkinData.equipped_bat
	equipped_crow = SkinData.equipped_crow
	$CrowPreview.texture = SkinData.get_texture(SkinData.KIND_CROW, equipped_crow)
	$BatPreview.texture = SkinData.get_texture(SkinData.KIND_BAT, equipped_bat)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
