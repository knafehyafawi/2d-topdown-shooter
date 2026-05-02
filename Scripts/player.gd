extends CharacterBody2D


const SPEED = 500.0
var input_dir = Vector2()
const BULLET_SPEED = 2000

@onready var bullet: RigidBody2D = $"../Bullet"



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
	

func fire():
	var bullet_instance = bullet.instance()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_deg = rotation_degrees
	bullet_instance.apply_impulse(Vector2(),Vector2(BULLET_SPEED,0).rotated(rotation))
	
	get_tree().get_root().call_deferred("add_child",bullet_instance)

func _physics_process(delta: float) -> void:
	player_movement()
	move_and_slide()
	
	if Input.is_action_just_pressed("fire"):
		fire()
