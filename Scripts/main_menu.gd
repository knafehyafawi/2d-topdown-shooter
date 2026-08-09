extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_itchio_button_pressed() -> void:
	OS.shell_open("https://knafehyafawi.itch.io/")


func _on_git_hub_button_pressed() -> void:
	OS.shell_open("https://github.com/knafehyafawi/2d-topdown-shooter")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits_menu.tscn")


func _on_ng_button_pressed() -> void:
	OS.shell_open("https://adash619.newgrounds.com/")
