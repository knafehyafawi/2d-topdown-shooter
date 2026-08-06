extends CanvasLayer

@onready var  score_label: Label = $MarginContainer/ScoreLabel

func update_score(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)
