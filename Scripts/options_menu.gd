extends CanvasLayer


func _on_back_button_pressed() -> void:
	AudioManager.play_back()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
