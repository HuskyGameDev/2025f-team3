extends CanvasLayer

@export var button_group: ButtonGroup
var selected_tower = "-1"
var buying_tower = false
signal begin_buying(selected)

# Objective health tracking
var objective_health: float = 500
var objective_max_health: float = 500
var objective_health_width

# Dictionary containing info for available towers.
# Info is accessed with tower_info[x][y] such that x is the dictionary key and y is the tower ID.
@export var tower_info = {
	# Name
	0: [
		"Crossbow Tower",
		"Cauldron Tower",
		"Tower 2",
		"Tower 3"
	],
	# Health
	1: [1, 2, 3, 4],
	# Damage
	2: [10, 6, 4, 5],
	# Speed
	3: [1, 3, 5, 6],
	# Description
	4: [
		"The crossbow tower fires arrows at the nearest enemy.",
		"The cauldron tower pours down boiling oil onto surrounding enemies.",
		"This is tower 2. It's a tower. Yeah!",
		"This is tower 3. It's a tower. Yeah!"
	],
	# Price
	5: [100, 200, 300, 400]
}

func _get_price(i):
	return tower_info[5][i]

func _select_tower(i):
	if i == "-1":
		_reset_tower_values()
	else:
		$LeftPanel/VBoxContainer/Name.text = str(tower_info[0][int(i)])
		$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/HealthBox/Health.text = str(tower_info[1][int(i)])
		$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/DamageBox/Damage.text = str(tower_info[2][int(i)])
		$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/SpeedBox/Speed.text = str(tower_info[3][int(i)])
		$LeftPanel/VBoxContainer/Description.text = str(tower_info[4][int(i)])
		$LeftPanel/VBoxContainer/Price/Label.text = str(tower_info[5][int(i)])
		
func _reset_tower_values():
	$LeftPanel/VBoxContainer/Name.text = "No tower selected"
	$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/HealthBox/Health.text = "N/A"
	$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/DamageBox/Damage.text = "N/A"
	$LeftPanel/VBoxContainer/MarginContainer/VBoxContainer/SpeedBox/Speed.text = "N/A"
	$LeftPanel/VBoxContainer/Description.text = "Select a tower to see its statistics, description, and price. Click Buy to place the tower on the map."
	$LeftPanel/VBoxContainer/Price/Label.text = "N/A"

func _ready() -> void:
	_reset_tower_values()

	# Initialize objective health bar
	await get_tree().process_frame
	objective_health_width = 320 # NOTE: Hard coded because it ended up being zero every time
	print("objective_health_width:")
	print(objective_health_width)
	# Connect to objective signals
	_connect_to_objective()

var t = 0.0

func _process(delta: float) -> void:
	t += delta
	
	# Update objective health bar
	if objective_health_width > 0:
		var health_percent = objective_health / objective_max_health
		$ObjectivePanel/VBoxContainer/ObjectiveHealthRect.size.x = objective_health_width * health_percent
		$ObjectivePanel/VBoxContainer/HBoxContainer/ObjectiveHealthLabel.text = str(int(objective_health), "/", int(objective_max_health), " ")
	# Update position of buying panel
	if buying_tower:
		$BuyingPanel.visible = true#position = $BuyingPanel.position.lerp(Vector2(389, 622), t)
	else:
		$BuyingPanel.visible = false#position = $BuyingPanel.position.lerp(Vector2(389, 722), t)\
	
	if selected_tower == "-1" or buying_tower == true:
		$LeftPanel/VBoxContainer/Buy.disabled = true
	else:
		$LeftPanel/VBoxContainer/Buy.disabled = false

func _on_button_pressed() -> void:
	if button_group.get_pressed_button() == null:
		selected_tower = "-1"
	else:
		selected_tower = button_group.get_pressed_button().name
		
	_select_tower(selected_tower)

func _on_buy_pressed() -> void:
	$BuyingPanel/Label.text = str("Currently buying ", str(tower_info[0][int(selected_tower)]), ". Click anywhere on the map to place the tower or press the X key to cancel tower placement.")
	buying_tower = true
	begin_buying.emit(selected_tower)
	$LeftPanel/VBoxContainer/Buy.disabled = true
	
func _connect_to_objective() -> void:
	# Find and connect to the objective in the scene
	var objectives = get_tree().get_nodes_in_group("objective")
	if objectives.size() > 0:
		var objective = objectives[0]
		objective_max_health = objective.get_max_health()
		objective_health = objective.get_health()
		print("2D HUD connected to objective")
	else:
		push_warning("2D HUD: No objective found in scene!")

func _on_game_manager_end_buying() -> void:
	$LeftPanel/VBoxContainer/Buy.disabled = false
	buying_tower = false
	
func _on_game_manager_update_gold(value: Variant) -> void:
	$LeftPanel/VBoxContainer/GoldBox/Gold.text = str(value)

# Update UI health on objective health change
func _on_objective_damaged_sig(damage_taken: Variant, health_after_damage: Variant) -> void:
	objective_health = health_after_damage
