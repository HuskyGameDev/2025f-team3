extends PanelContainer

func _ready() -> void:
	pass # Settings would be loaded from a prefs file in this function

func _on_back_pressed() -> void:
	visible = false

#!# When volume sliders are changed, the value will determine the volume variables in the prefs file.
#!# Any audio players should use the prefs file and set the volume accordingly.

# Main volume slider
func _on_h_slider_value_changed(value: float) -> void:
	pass # Replace with function body.

# Music volume slider
func _on_h_slider_value_changed_music(value: float) -> void:
	pass # Replace with function body.

# SFX volume slider
func _on_h_slider_value_changed_sfx(value: float) -> void:
	pass # Replace with function body.
