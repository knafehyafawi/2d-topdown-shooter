extends CharacterBody2D

@export var speed = 200.0
@export var bullet_speed = 1000
var input_dir = Vector2()

@onready var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")

var score: int = 0

func _ready() -> void:
	apply_settings()
	SettingsManager.settings_changed.connect(apply_settings)

func apply_settings() -> void:
	$DirectionArrow.visible = SettingsManager.DirectionArrow_enabled
	$AimCrosshair.visible = SettingsManager.AimCrosshair_enabled
	if not get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN if SettingsManager.AimCrosshair_enabled else Input.MOUSE_MODE_VISIBLE

func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(_delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "up", "down")
	$AimCrosshair.global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$"../pause_menu".visible = true
		$"../HUD".visible = false

################ debug func, do not delete ###################
#func _draw():
	#draw_circle(Vector2.ZERO, 3, Color.RED)  # mark player origin
	#draw_circle(Vector2(20, 0), 3, Color.GREEN)  # mark spawn point in local space
#########################################################

func player_movement() -> void:
	if input_dir:
		velocity = input_dir.normalized() * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
	
	look_at(get_global_mouse_position())

func fire():
	################ debug, do not delete ###################
	#print("Player global pos: ", global_position)
	#print("Spawn pos: ", global_position + Vector2(20, 0).rotated(rotation))
	#########################################################
	
	#var sfx_index = AudioServer.get_bus_index("SFX")
	#print("SFX volume_db: ", AudioServer.get_bus_volume_db(sfx_index))
	#print("SFX muted: ", AudioServer.is_bus_mute(sfx_index))
	$ShootSound.play()
	#print("SFX bus index at fire time: ", AudioServer.get_bus_index("SFX"))
	
	var bullet_instance = bullet_scene.instantiate()
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	bullet_instance.position = get_global_position()
	bullet_instance.rotation = rotation
	bullet_instance.apply_impulse(Vector2(bullet_speed, 0).rotated(rotation))
	

func _physics_process(_delta: float) -> void:
	player_movement()
	move_and_slide()
	if Input.is_action_just_pressed("fire"):
		fire()

func kill():
	get_tree().paused = true
	$"../HUD".hide()
	$"../DeathMenu".show_game_over(score)

func _on_area_2d_body_entered(body: Node2D) -> void:
	#################### debug!!!!!!! ####################
	#print("Killed by: ", body.name, " at position: ", body.global_position, " | player at: ", global_position, " | distance: ", body.global_position.distance_to(global_position))
	if body.is_in_group("enemies"):
		if body.has_method("get") and body.can_deal_damage:
			kill()
