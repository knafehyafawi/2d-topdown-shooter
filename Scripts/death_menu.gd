extends CanvasLayer

@onready var score_label: Label = $ScoreLabel

func show_game_over(score: int) -> void:
	visible = true
	score_label.text = "Score: " + str(score)

func _on_button_play_again_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_button_quit_pressed() -> void:
	get_tree().quit()
