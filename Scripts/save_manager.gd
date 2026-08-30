extends Node

var high_score: int = 0
var achievements: Dictionary = {}

const SAVE_PATH = "user://save.dat"

func _ready() -> void:
	load_game()

func save_game() -> void:
	var save_data = {
		"high_score": high_score,
		"achievements": achievements
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(save_data)
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var save_data = file.get_var()
	file.close()
	high_score = save_data.get("high_score", 0)
	achievements = save_data.get("achievements", {})

func check_high_score(current_score: int) -> bool:
	if current_score > high_score:
		high_score = current_score
		save_game()
		return true
	return false

func unlock_achievement(id: String) -> void:
	if not achievements.get(id, false):
		achievements[id] = true
		save_game()
