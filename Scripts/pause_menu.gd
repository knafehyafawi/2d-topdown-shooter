extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	AudioManager.play_select()
	get_parent().get_node("HUD").visible = true


func _on_return_to_menu_button_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_back()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
