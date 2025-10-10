extends PanelContainer

var main_volume
var music_volume
var sfx_volume

var settings

func _ready() -> void:
	settings = ConfigFile.new()
	var main_volume = $BoxContainer/MainVolume/HSlider.value
	var music_volume = $BoxContainer/MusicVolume/HSlider.value
	var sfx_volume = $BoxContainer/SFXVolume/HSlider.value
	
	if settings.load("res://assets/settings.cfg") != OK:
		settings.set_value("settings", "main_volume", main_volume)
		settings.set_value("settings", "music_volume", music_volume)
		settings.set_value("settings", "sfx_volume", sfx_volume)
		
		settings.save("res://assets/settings.cfg")
		
		return
	
	main_volume = settings.get_value("settings", "main_volume")
	music_volume = settings.get_value("settings", "music_volume")
	sfx_volume = settings.get_value("settings", "sfx_volume")
	$BoxContainer/MainVolume/HSlider.value = main_volume
	$BoxContainer/MusicVolume/HSlider.value = music_volume
	$BoxContainer/SFXVolume/HSlider.value = sfx_volume
	
	settings.save("res://assets/settings.cfg")

func _on_back_pressed() -> void:
	visible = false

#!# When volume sliders are changed, the value will determine the volume variables in the prefs file.
#!# Any audio players should use the prefs file and set the volume accordingly.

# Main volume slider
func _on_h_slider_value_changed(value: float) -> void:
	main_volume = value
	$BoxContainer/MainVolume/HSlider.value = main_volume
	settings.set_value("settings", "main_volume", main_volume)
	settings.save("res://assets/settings.cfg")

# Music volume slider
func _on_h_slider_value_changed_music(value: float) -> void:
	music_volume = value
	$BoxContainer/MusicVolume/HSlider.value = music_volume
	settings.set_value("settings", "music_volume", music_volume)
	settings.save("res://assets/settings.cfg")

# SFX volume slider
func _on_h_slider_value_changed_sfx(value: float) -> void:
	sfx_volume = value
	$BoxContainer/SFXVolume/HSlider.value = sfx_volume
	settings.set_value("settings", "sfx_volume", sfx_volume)
	settings.save("res://assets/settings.cfg")

func _on_reset_pressed() -> void:
	main_volume = 100
	music_volume = 100
	sfx_volume = 100
	$BoxContainer/MainVolume/HSlider.value = main_volume
	$BoxContainer/MusicVolume/HSlider.value = music_volume
	$BoxContainer/SFXVolume/HSlider.value = sfx_volume
	settings.set_value("settings", "main_volume", main_volume)
	settings.set_value("settings", "music_volume", music_volume)
	settings.set_value("settings", "sfx_volume", sfx_volume)
	settings.save("res://assets/settings.cfg")
