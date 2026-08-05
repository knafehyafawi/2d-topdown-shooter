extends CanvasLayer

func _on_button_play_again_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_button_quit_pressed() -> void:
	get_tree().quit()
