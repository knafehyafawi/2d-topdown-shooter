extends CanvasLayer

@onready var score_label: Label = $"MarginContainer/HUDOrg/ScoreLabel"
@onready var health_bar = $MarginContainer/HUDOrg/HealthBar

func _ready() -> void:
	apply_settings()
	SettingsManager.settings_changed.connect(apply_settings)

func apply_settings() -> void:
	score_label.visible = SettingsManager.ScoreDisplay_enabled

func update_score(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)

func update_health(current: int, max_hp: int) -> void:
	health_bar.update_health(current, max_hp)
