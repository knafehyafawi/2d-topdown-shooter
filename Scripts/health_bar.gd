extends Control

@onready var progress_bar: ProgressBar = $HBoxContainer/ProgressBar
@onready var hp_label: Label = $HBoxContainer/HPLabel

func update_health(current: int, max_hp: int) -> void:
	progress_bar.max_value = max_hp
	progress_bar.value = current
	hp_label.text = "HP: " + str(current) + "/" + str(max_hp)
	
	print("ProgressBar updated. max_value: ", progress_bar.max_value, " | value: ", progress_bar.value)
