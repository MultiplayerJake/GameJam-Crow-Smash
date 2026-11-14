extends CharacterBody2D

signal hit_wall

var speed: float = 500.0
@export var max_deviation_degrees: float = 5.0 # Small deviation angle for walls

func _ready() -> void:
	# Give the ball an initial movement direction (e.g., top-right)
	velocity = Vector2(1, -1).normalized() * speed

func _physics_process(delta: float) -> void:
	# Move the ball and check for collisions
	var collision := move_and_collide(velocity * delta)
	
	if collision:
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		
		# 1. Calculate standard reflection bounce off the surface normal
		velocity = velocity.bounce(normal)
		
		# 2. Check which type of object was hit using groups
		if collider.is_in_group("walls"):
			hit_wall.emit()
			# Add a small random deviation (converted from degrees to radians)
			var random_deg = randf_range(-max_deviation_degrees, max_deviation_degrees)
			velocity = velocity.rotated(deg_to_rad(random_deg))
			
		elif collider.is_in_group("blocks"):
			# Standard bounce: do nothing extra, it reflects cleanly
			pass
			
		# Keep speed consistent after the bounce
		velocity = velocity.normalized() * speed
	
	if velocity != Vector2(0,0):
		$Sprite2D.rotation += 0.1
