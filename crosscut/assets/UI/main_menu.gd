extends CanvasLayer

@onready var menu_music: AudioStreamPlayer = get_parent().get_node("MenuMusic")

func _ready() -> void: 
	menu_music.play()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/test_scene.tscn")

func _on_settings_pressed() -> void:
	$MainPanel/Settings.visible = true

func _on_credits_pressed() -> void:
	$MainPanel/Credits.visible = true

func _on_back2_pressed() -> void:
	$MainPanel/Credits.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_controls_pressed() -> void:
	$MainPanel/Controls.visible = true

func _on_back3_pressed() -> void:
	$MainPanel/Controls.visible = false
