extends CanvasLayer

@export var button_group: ButtonGroup
var selected_tower

# Objective health tracking
var objective_health: float = 500
var objective_max_health: float = 500
var objective_health_width

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

	# Initialize objective health bar
	await get_tree().process_frame
	objective_health_width = $ObjectivePanel/VBoxContainer/ObjectiveHealthRect.size.x

	# Connect to objective signals
	_connect_to_objective()

func _process(delta: float) -> void:
	# Update objective health bar
	if objective_health_width > 0:
		var health_percent = objective_health / objective_max_health
		$ObjectivePanel/VBoxContainer/ObjectiveHealthRect.size.x = objective_health_width * health_percent
		$ObjectivePanel/VBoxContainer/HBoxContainer/ObjectiveHealthLabel.text = str(int(objective_health), "/", int(objective_max_health))

func _on_button_pressed() -> void:
	if button_group.get_pressed_button() == null:
		selected_tower = "-1"
	else:
		selected_tower = button_group.get_pressed_button().name
		
	_select_tower(selected_tower)

func _on_buy_pressed() -> void:
	print(str("You just bought tower "), selected_tower)

func _connect_to_objective() -> void:
	# Find and connect to the objective in the scene
	var objectives = get_tree().get_nodes_in_group("objective")
	if objectives.size() > 0:
		var objective = objectives[0]
		objective_max_health = objective.get_max_health()
		objective_health = objective.get_health()
		objective.objective_damaged.connect(_on_objective_damaged)
		print("2D HUD connected to objective")
	else:
		push_warning("2D HUD: No objective found in scene!")

func _on_objective_damaged(current_health: float, max_health: float) -> void:
	objective_health = current_health
	objective_max_health = max_health
