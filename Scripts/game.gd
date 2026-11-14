extends Node2D

@onready var score_label: Label = $ScoreLabel
@onready var lose_label: Label = $LoseLabel
@onready var reset_button = $"Reset button"
@onready var high_score_label: Label = $HighScoreLabel
@onready var coins_label: Label = $CoinsLabel

const HIGH_SCORE_PATH := "res://Saves/high_score.save"
const COINS_PATH := "res://Saves/coins.save"
var high_score: int = 0
var coins: int = 0
var menu_scene = "res://Scenes/MainScenes/menu.tscn"
var score: int = 0
var has_lost: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lose_label.visible = false
	reset_button.visible = false
	_load_high_score()
	_load_coins()
	_update_high_score_label()
	_update_coins_label()
	$ball.hit_wall.connect(_on_ball_hit_wall)
	$"Detection area".body_entered.connect(_on_detection_area_body_entered)
	_update_score_label()


func _load_high_score() -> void:
	if not FileAccess.file_exists(HIGH_SCORE_PATH):
		return
	var f := FileAccess.open(HIGH_SCORE_PATH, FileAccess.READ)
	if f:
		high_score = int(f.get_as_text().strip_edges())


func _load_coins() -> void:
	if not FileAccess.file_exists(COINS_PATH):
		return
	var f := FileAccess.open(COINS_PATH, FileAccess.READ)
	if f:
		coins = int(f.get_as_text().strip_edges())


func _save_high_score() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://Saves"))
	var f := FileAccess.open(HIGH_SCORE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(str(high_score))


func _save_coins() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://Saves"))
	var f := FileAccess.open(COINS_PATH, FileAccess.WRITE)
	if f:
		f.store_string(str(coins))


func _update_high_score_label() -> void:
	high_score_label.text = "High Score: %d" % high_score


func _update_coins_label() -> void:
	coins_label.text = "Coins: %d" % coins


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_ball_hit_wall() -> void:
	if has_lost:
		return
	_award_coins()
	score += 1
	if score > high_score:
		high_score = score
		_update_high_score_label()
		_save_high_score()
	_update_score_label()


func _award_coins() -> void:
	coins += clampi(1 + score / 10, 1, 5)
	_save_coins()
	_update_coins_label()


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
