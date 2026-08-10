extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_interval: float = 7.5
@export var min_spawn_interval: float = 0.5
@export var interval_decay_per_second: float = 0.02
@export var enemies_per_spawn: int = 1
@export var min_spawn_distance: float = 400.0
@export var screen_margin: float = 100.0

@onready var spawn_timer: Timer = $SpawnTimer

var spawn_points: Array[Marker2D] = []
var elapsed_time: float = 0.0

func _ready() -> void:
	#print("--- EnemySpawner _ready() called ---") #debug
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)
	
	############ for debugging ###########################
	#print("Spawn points found: ", spawn_points.size())
	#print("Enemy scenes assigned: ", enemy_scenes.size())
	#print("Timer one_shot: ", spawn_timer.one_shot)
	######################################################
	
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	#print("Timer started, wait_time: ", spawn_timer.wait_time) #debug

func _process(delta: float) -> void:
	elapsed_time += delta
	var current_interval = max(min_spawn_interval, spawn_interval - (elapsed_time * interval_decay_per_second))
	spawn_timer.wait_time = current_interval

func _on_spawn_timer_timeout() -> void:
	#print("--- Timer timeout fired at ", Time.get_ticks_msec(), "ms ---") #debug
	for i in enemies_per_spawn:
		spawn_enemy()

func is_off_screen(pos: Vector2) -> bool:
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return true
	var screen_size = get_viewport().get_visible_rect().size
	var cam_pos = camera.get_screen_center_position()
	var half_extents = (screen_size / camera.zoom) / 2.0 + Vector2(screen_margin, screen_margin)
	var screen_rect = Rect2(cam_pos - half_extents, half_extents*2)
	return not screen_rect.has_point(pos)

func spawn_enemy() -> void:
	if enemy_scenes.is_empty() or spawn_points.is_empty():
		return
	
	var player = get_parent().get_node("Player")
	#print("Player position: ", player.global_position) # debug
	
	var valid_points: Array[Marker2D] = []
	for point in spawn_points:
		var dist = point.global_position.distance_to(player.global_position)
		#print("Marker at ", point.global_position, " is ", dist, " px from player") # debug
		if dist >= min_spawn_distance and is_off_screen(point.global_position):
			valid_points.append(point)
	
	if valid_points.is_empty():
		valid_points = spawn_points
	
	var enemy_scene: PackedScene = enemy_scenes.pick_random()
	var spawn_point: Marker2D = valid_points.pick_random()
	
	var enemy_instance = enemy_scene.instantiate()
	get_parent().add_child(enemy_instance)
	enemy_instance.global_position = spawn_point.global_position
