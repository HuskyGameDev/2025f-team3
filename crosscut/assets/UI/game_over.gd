extends CanvasLayer

func _ready() -> void:
	hide()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/scenes/main_menu_scene.tscn")
