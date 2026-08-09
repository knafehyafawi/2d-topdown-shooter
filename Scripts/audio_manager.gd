extends Node

@onready var select_button_sound: AudioStreamPlayer = $SFX/SelectButtonSound
@onready var back_button_sound: AudioStreamPlayer = $SFX/BackButtonSound

func play_select():
	select_button_sound.play()

func play_back():
	back_button_sound.play()
