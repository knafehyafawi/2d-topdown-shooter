extends CharacterBody2D

@export var max_health: int = 5
var health: int

@export var speed: float = 200.0
var motion = Vector2()

@onready var base_color: Color = $Sprite2D.modulate

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var can_deal_damage: bool = false

var last_position: Vector2 = Vector2.ZERO
var stuck_check_timer: float = 0.0


func _ready() -> void:
	health = max_health
	await get_tree().create_timer(0.2).timeout
	can_deal_damage = true

func _physics_process(_delta: float) -> void:
	var player = get_parent().get_node("Player")
	
	nav_agent.target_position = player.global_position
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	velocity = direction * speed
	
	stuck_check_timer += _delta
	if stuck_check_timer >= 0.5:
		if global_position.distance_to(last_position) < 10.0:
			var nudge_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			global_position += nudge_direction * 8.0
		last_position = global_position
		stuck_check_timer = 0.0
	
	
	#################### debugging ##########################################################################################################################################################################################################################
	if Engine.get_physics_frames() % 30 == 0:
		print("Enemy pos: ", global_position, " | stuck_check_timer: ", stuck_check_timer, " | next_pos: ", nav_agent.get_next_path_position(), " | target: ", nav_agent.target_position, " | reachable: ", nav_agent.is_target_reachable())
	#################### debugging ##########################################################################################################################################################################################################################
	
	look_at(next_pos)
	move_and_slide()

############################# tenative func for enemy ai adjustments ##################################################
#func has_line_of_sight_to_player(player_pos: Vector2) -> bool:
	#var space_state = get_world_2d().direct_space_state
	#var query = PhysicsRayQueryParameters2D.create(global_position, player_pos, 1) # layer 1 = walls
	#var result = space_state.intersect_ray(query)
	#return result.is_empty()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		var player = get_parent().get_node("Player")
		player.score += 1
		get_parent().get_node("HUD").update_score(player.score)
		
		var death_sound = $DeathSound
		#print("SFX bus index at death time: ", AudioServer.get_bus_index("SFX"))
		
		remove_child(death_sound)
		get_tree().get_root().add_child(death_sound)
		death_sound.global_position = global_position
		death_sound.play()
		death_sound.finished.connect(death_sound.queue_free)
		
		queue_free()
	else:
		flash_hit()

func flash_hit() -> void:
	$Sprite2D.modulate = base_color * 3.0
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", base_color, 0.15)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("bullets"):
		body.queue_free()
		take_damage(1)
