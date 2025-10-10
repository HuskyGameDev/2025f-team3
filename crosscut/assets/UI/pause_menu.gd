extends CanvasLayer

func _ready() -> void:
	hide()

func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #go back to mouse camera controls

func _on_settings_pressed() -> void:
	$SettingsMenu.visible = true

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/scenes/main_menu_scene.tscn")

func _input(event):
	if event.is_action_pressed("Pause"):
		if get_tree().paused == false:
			show()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE		
			get_tree().paused = true
		else: #Be able to hit escape again in order to exit the pause menu
			hide()
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 
