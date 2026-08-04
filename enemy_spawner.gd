extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_interval: float = 3.0
@export var enemies_per_spawn: int = 1

@onready var spawn_timer: Timer = $SpawnTimer
var spawn_points: Array[Marker2D] = []

func _ready() -> void:
	print("--- EnemySpawner _ready() called ---") #debug
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)
	
	############ for debugging ###########################
	print("Spawn points found: ", spawn_points.size())
	print("Enemy scenes assigned: ", enemy_scenes.size())
	print("Timer one_shot: ", spawn_timer.one_shot)
	######################################################
	
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	print("Timer started, wait_time: ", spawn_timer.wait_time) #debug

func _on_spawn_timer_timeout() -> void:
	print("--- Timer timeout fired at ", Time.get_ticks_msec(), "ms ---") #debug
	for i in enemies_per_spawn:
		spawn_enemy()

func spawn_enemy() -> void:
	if enemy_scenes.is_empty() or spawn_points.is_empty():
		print("spawn_enemy() aborted — enemy_scenes empty: ", enemy_scenes.is_empty(), " spawn_points empty: ", spawn_points.is_empty()) #debug
		return
	
	var enemy_scene: PackedScene = enemy_scenes.pick_random()
	var spawn_point: Marker2D = spawn_points.pick_random()
	
	var enemy_instance = enemy_scene.instantiate()
	get_parent().add_child(enemy_instance)
	enemy_instance.global_position = spawn_point.global_position
	print("Spawned enemy at: ", spawn_point.global_position) #debug
