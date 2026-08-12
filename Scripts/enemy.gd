extends CharacterBody2D

@export var max_health: int = 5
var health: int

@export var speed: float = 150.0
var motion = Vector2()

@onready var base_color: Color = $Sprite2D.modulate

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var can_deal_damage: bool = false

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
	
	look_at(next_pos)
	move_and_slide()

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
