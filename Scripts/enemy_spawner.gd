extends Node2D

@export var enemy_scenes: Array[PackedScene] = []
@export var base_weights: Array[float] = [1.0, 0.0, 0.0]
@export var late_weights: Array[float] = [0.4, 0.3, 0.3]
@export var ramp_duration: float = 120.0
@export var spawn_interval: float = 7.0
@export var min_spawn_interval: float = 0.25
@export var interval_decay_per_second: float = 0.02
@export var enemies_per_spawn: int = 1
@export var min_spawn_distance: float = 400.0
@export var screen_margin: float = 100.0

@onready var spawn_timer: Timer = $SpawnTimer

var spawn_points: Array[Vector2] = []
var elapsed_time: float = 0.0
var is_active: bool = false

func start_spawning(points: Array) -> void:
	spawn_points.clear()
	for p in points:
		spawn_points.append(p)
	is_active = true
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _process(delta: float) -> void:
	if not is_active:
		return
	elapsed_time += delta
	var current_interval = max(min_spawn_interval, spawn_interval - (elapsed_time * interval_decay_per_second))
	spawn_timer.wait_time = current_interval

func _on_spawn_timer_timeout() -> void:
	for i in enemies_per_spawn:
		spawn_enemy()

func is_off_screen(pos: Vector2) -> bool:
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return true
	var screen_size = get_viewport().get_visible_rect().size
	var cam_pos = camera.get_screen_center_position()
	var half_extents = (screen_size / camera.zoom) / 2.0 + Vector2(screen_margin, screen_margin)
	var screen_rect = Rect2(cam_pos - half_extents, half_extents * 2)
	return not screen_rect.has_point(pos)

func get_current_weights() -> Array[float]:
	var t = clamp(elapsed_time/ramp_duration, 0.0, 1.0)
	var weights: Array[float] = []
	for i in enemy_scenes.size():
		weights.append(lerp(base_weights[i], late_weights[i], t))
	return weights

func pick_weighted_enemy() -> PackedScene:
	var weights = get_current_weights()
	var total = 0.0
	for w in weights:
		total+= w
	
	var roll = randf() * total
	var cumulative = 0.0
	for i in weights.size():
		cumulative += weights[i]
		if roll <= cumulative:
			return enemy_scenes[i]
	
	return enemy_scenes[enemy_scenes.size()-1]

func spawn_enemy() -> void:
	if enemy_scenes.is_empty() or spawn_points.is_empty():
		return
	
	var player = get_parent().get_node("Player")
	
	var valid_points: Array[Vector2] = []
	for point in spawn_points:
		var dist = point.distance_to(player.global_position)
		if dist >= min_spawn_distance and is_off_screen(point):
			valid_points.append(point)
	
	if valid_points.is_empty():
		valid_points = spawn_points
	
	var enemy_scene: PackedScene = pick_weighted_enemy()
	var spawn_point: Vector2 = valid_points.pick_random()
	
	var enemy_instance = enemy_scene.instantiate()
	get_parent().add_child(enemy_instance)
	enemy_instance.global_position = spawn_point
