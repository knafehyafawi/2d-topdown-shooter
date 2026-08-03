extends RigidBody2D

func _ready():
	gravity_scale = 0
	lock_rotation = true
	freeze = false  # true only when debugging
	# print("Bullet spawned at: ", global_position)


# collision detection in case collision with wall happens
func _on_body_entered(body: Node) -> void:
	queue_free()
