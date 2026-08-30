extends Control

@onready var fill_bar: ColorRect = $HBoxContainer/Bar/FillBar
@onready var bg_bar: ColorRect = $HBoxContainer/Bar/BGBar

func update_health(current: int, max_hp: int) -> void:
	var fill_ratio = float(current) / float(max_hp)
	fill_bar.custom_minimum_size.x = bg_bar.size.x * fill_ratio
