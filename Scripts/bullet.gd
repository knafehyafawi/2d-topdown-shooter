extends RigidBody2D

@export var damage: int = 1

func _ready():
	gravity_scale = 0
	lock_rotation = true
	freeze = false # true only when debugging
	# print("Bullet spawned at: ", global_position)
	

# collision detection in case collision with wall or enemy happens
func _on_body_entered(_body: Node) -> void:
	queue_free()
	
