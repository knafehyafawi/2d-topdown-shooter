extends CharacterBody2D

@export var max_health: int = 3
var health: int

#const SPEED = 300.0
var motion = Vector2()

#@onready var player: PackedScene = preload("res://Scenes/player.tscn")

func _ready() -> void:
	health = max_health

func _physics_process(delta: float) -> void:
	var player = get_parent().get_node("Player")
	position += (player.position - position) / 50
	look_at(player.position)
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("bullets"):
		body.queue_free()
		take_damage(1)
