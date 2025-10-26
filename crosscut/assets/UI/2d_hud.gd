extends CanvasLayer

@export var button_group: ButtonGroup
var selected_tower

func _select_tower(i):
	if i == "-1":
		$LeftPanel/VBoxContainer/Name.text = "No tower selected"
		$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/HealthBox/Health.text = "N/A"
		$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/DamageBox/Damage.text = "N/A"
		$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/SpeedBox/Speed.text = "N/A"
		$LeftPanel/VBoxContainer/Description.text = "Select a tower to see its statistics, description, and price."
		$LeftPanel/VBoxContainer/Price/Label.text = "N/A"
	if i == "0":
		$LeftPanel/VBoxContainer/Name.text = "Tower 0"
		$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/HealthBox/Health.text = "1"
		$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/DamageBox/Damage.text = "2"
		$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/SpeedBox/Speed.text = "3"
		$LeftPanel/VBoxContainer/Description.text = "This is tower 0. It's a tower. Yeah!"
		$LeftPanel/VBoxContainer/Price/Label.text = "100"

func _ready() -> void:
	$LeftPanel/VBoxContainer/Name.text = "No tower selected"
	$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/HealthBox/Health.text = "N/A"
	$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/DamageBox/Damage.text = "N/A"
	$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/SpeedBox/Speed.text = "N/A"
	$LeftPanel/VBoxContainer/Description.text = "Select a tower to see its statistics, description, and price."
	$LeftPanel/VBoxContainer/Price/Label.text = "N/A"

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	if button_group.get_pressed_button() == null:
		selected_tower = "-1"
	else:
		selected_tower = button_group.get_pressed_button().name
		
	_select_tower(selected_tower)

func _on_buy_pressed() -> void:
	print(str("You just bought tower "), selected_tower)
