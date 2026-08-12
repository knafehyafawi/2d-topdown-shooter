extends CanvasLayer

@onready var score_label: Label = $ScoreLabel

func _ready() -> void:
	$Button_Quit.visible = not PlatformUtils.is_web_build()

func show_game_over(score: int) -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	score_label.text = "Score: " + str(score)
	

func _on_button_play_again_pressed() -> void:
	AudioManager.play_select()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_button_quit_pressed() -> void:
	AudioManager.play_back()
	get_tree().quit()

func _on_main_menu_pressed() -> void:
	AudioManager.play_select()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
