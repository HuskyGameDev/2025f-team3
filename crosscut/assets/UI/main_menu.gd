extends CanvasLayer

func _ready() -> void: 
	AudioManager.play_music("menu")

func _on_play_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	get_tree().change_scene_to_file("res://assets/scenes/test_scene.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	%SettingsMenu.visible = true

func _on_credits_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	$Credits.visible = true

func _on_back2_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	$Credits.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_controls_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	%Controls.visible = true
