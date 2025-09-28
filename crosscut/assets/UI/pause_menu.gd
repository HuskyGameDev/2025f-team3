extends CanvasLayer

func _on_resume_pressed() -> void:
	queue_free()
	# get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://assets/scenes/main_menu_scene.tscn")
