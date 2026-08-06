extends CanvasLayer


@export var credits: Array[String] = [
	"Game by knafehyafawi",
	"Font: SevenFifteen by Douglas Vautour (Burpy Fresh) - CC by 4.0",
	"",
	"Made in Godot 4.6.2",
	"",
	"Thank you for playing! :)"
]

func _ready() -> void:
	visible = true
	for line in credits:
		var label = Label.new()
		label.text = line
		$ScrollContainer/CreditsList.add_child(label)

func _on_credits_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_itchio_button_pressed() -> void:
	OS.shell_open("https://knafehyafawi.itch.io/")


func _on_git_hub_button_pressed() -> void:
	OS.shell_open("https://github.com/knafehyafawi/2d-topdown-shooter")


func _on_ng_button_pressed() -> void:
	OS.shell_open("https://adash619.newgrounds.com/")
