extends CharacterBody2D

const SPEED = 500.0
const BULLET_SPEED = 1000
var input_dir = Vector2()

@onready var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")

func _process(delta: float) -> void:
		input_dir = Input.get_vector("left", "right", "up", "down")
		# queue_redraw()

################ debug, do not delete ###################
#func _draw():
	#draw_circle(Vector2.ZERO, 3, Color.RED)  # mark player origin
	#draw_circle(Vector2(20, 0), 3, Color.GREEN)  # mark spawn point in local space
#########################################################

func player_movement() -> void:
	if input_dir:
		velocity = input_dir.normalized() * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	look_at(get_global_mouse_position())

func fire():
	################ debug, do not delete ###################
	#print("Player global pos: ", global_position)
	#print("Spawn pos: ", global_position + Vector2(20, 0).rotated(rotation))
	#########################################################
	
	var bullet_instance = bullet_scene.instantiate()
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	bullet_instance.position = get_global_position()
	bullet_instance.rotation = rotation
	bullet_instance.apply_impulse(Vector2(BULLET_SPEED, 0).rotated(rotation))
	

func _physics_process(delta: float) -> void:
	player_movement()
	move_and_slide()
	if Input.is_action_just_pressed("fire"):
		fire()

func kill():
	get_tree().reload_current_scene()

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Touched: ", body.name, " | in enemies group: ", body.is_in_group("enemies"))
	if body.is_in_group("enemies"):
		kill()
