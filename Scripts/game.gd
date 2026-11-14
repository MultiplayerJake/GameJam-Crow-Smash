extends Node2D

@onready var score_label: Label = $ScoreLabel
@onready var lose_label: Label = $LoseLabel
@onready var reset_button = $"Reset button"

var menu_scene = "res://Scenes/MainScenes/menu.tscn"
var score: int = 0
var has_lost: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lose_label.visible = false
	reset_button.visible = false
	$ball.hit_wall.connect(_on_ball_hit_wall)
	$"Detection area".body_entered.connect(_on_detection_area_body_entered)
	_update_score_label()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ball_hit_wall() -> void:
	if has_lost:
		return
	score += 1
	_update_score_label()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if has_lost:
		return
	if body.is_in_group("ball"):
		_lose()


func _lose() -> void:
	has_lost = true
	score = 0
	_update_score_label()
	lose_label.visible = true
	reset_button.visible = true
	var ball = $ball
	ball.velocity = Vector2.ZERO
	ball.set_physics_process(false)


func _update_score_label() -> void:
	score_label.text = "Score: %d" % score


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var error = get_tree().change_scene_to_file(menu_scene)
		if error != OK:
			print("Failed to change scene, error code: ", error)
