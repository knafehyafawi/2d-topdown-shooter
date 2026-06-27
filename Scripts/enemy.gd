extends CharacterBody2D

#const SPEED = 300.0
var motion = Vector2()

#@onready var player: PackedScene = preload("res://Scenes/player.tscn")

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var player = get_parent().get_node("Player")
	
	position += (player.position-position)/50
	
	#velocity = player.position.normalized() * motion
	
	look_at(player.position)
	move_and_slide()

# TO DO:
# if bullet hits enemy, enemy take damage
# enemy has 5 max HP. bullet does 1 dmg
# also fix enemy spawn pos
