extends CanvasLayer

@export var button_group: ButtonGroup
var selected_tower

func _select_tower(i):
	print(str("You have selected tower ", i))

func _process(delta: float) -> void:
	pass
	
func _on_button_pressed() -> void:
	selected_tower = button_group.get_pressed_button().name
	_select_tower(selected_tower)
