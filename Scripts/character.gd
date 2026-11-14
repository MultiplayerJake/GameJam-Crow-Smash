extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var hit_speed_boost: float = 100.0
@export var max_ball_speed: float = 900.0

var is_swinging := false
var swing_hit := false


func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jatpack"):
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jatpack"):
		velocity.y = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if is_swinging and not swing_hit:
		_try_hit_ball()


func _try_hit_ball() -> void:
	for body in $Bat/BatHitbox.get_overlapping_bodies():
		if not body.is_in_group("ball"):
			continue

		swing_hit = true
		var outward: Vector2 = (body.global_position - global_position).normalized()
		var bat_direction: Vector2 = Vector2.RIGHT.rotated($Bat.global_rotation)
		var hit_direction: Vector2 = (outward + bat_direction).normalized()
		if hit_direction == Vector2.ZERO:
			hit_direction = outward

		body.speed = min(body.speed + hit_speed_boost, max_ball_speed)
		body.velocity = hit_direction * body.speed
		return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("swing"):
		$AudioStreamPlayer2D.play()
		$AnimationPlayer.play("BatSwing")
		is_swinging = true
		swing_hit = false


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "BatSwing":
		is_swinging = false
