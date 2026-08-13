extends VBoxContainer

func _ready() -> void:
	$ArrowCheckButton.button_pressed = SettingsManager.DirectionArrow_enabled
	$CrosshairCheckButton.button_pressed = SettingsManager.AimCrosshair_enabled
	$ShowScoreButton.button_pressed = SettingsManager.ScoreDisplay_enabled

func _on_arrow_check_button_toggled(toggled_on: bool) -> void:
	SettingsManager.DirectionArrow_enabled = toggled_on
	SettingsManager.settings_changed.emit()

func _on_crosshair_check_button_toggled(toggled_on: bool) -> void:
	SettingsManager.AimCrosshair_enabled = toggled_on
	SettingsManager.settings_changed.emit()

func _on_show_score_button_toggled(toggled_on: bool) -> void:
	SettingsManager.ScoreDisplay_enabled = toggled_on
	SettingsManager.settings_changed.emit()
