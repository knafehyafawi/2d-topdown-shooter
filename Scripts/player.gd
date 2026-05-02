extends CharacterBody2D


const SPEED = 500.0
var input_dir = Vector2()
# const JUMP_VELOCITY = -400.0


func _process(delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	
func player_movement()->void:
	if input_dir:
		velocity = input_dir.normalized() * SPEED
	else:
		velocity.x = move_toward(velocity.x,0,SPEED)
		velocity.y = move_toward(velocity.y,0,SPEED)
	
	# Aim
	look_at(get_global_mouse_position())


func _physics_process(delta: float) -> void:
	player_movement()
	move_and_slide()
