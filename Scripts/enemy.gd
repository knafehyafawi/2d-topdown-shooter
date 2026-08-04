extends CharacterBody2D

@export var max_health: int = 3
@export var speed: float = 150.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D


var health: int
var motion = Vector2()

func _ready() -> void:
	health = max_health

func _physics_process(delta: float) -> void:
	var player = get_parent().get_node("Player")
	nav_agent.target_position = player.global_position
	
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	velocity = direction * 150.0
	look_at(next_pos)
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
		print("Enemy dead")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("bullets"):
		body.queue_free()
		take_damage(1)
		print("Enemy health -1")
