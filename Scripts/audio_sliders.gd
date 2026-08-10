extends VBoxContainer

func _ready() -> void:
	#print("Master bus index: ", AudioServer.get_bus_index("Master"))
	#print("Music bus index: ", AudioServer.get_bus_index("Music"))
	#print("SFX bus index: ", AudioServer.get_bus_index("SFX"))
	#
	#print("Music volume before sync: ", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	
	$Master/MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$Music/MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	$SFX/SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	
	#print("Music slider value after sync: ", $Music/MusicSlider.value)

func _on_master_slider_value_changed(value: float) -> void:
	#print("Master slider moved to: ", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_slider_value_changed(value: float) -> void:
	#print("Music slider moved to: ", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	#print("SFX slider moved to: ", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
