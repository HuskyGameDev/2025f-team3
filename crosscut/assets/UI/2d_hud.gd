extends CanvasLayer
var library: Node
@export var button_group: ButtonGroup
@export var weapon_button_group: ButtonGroup
var selected_tower: String = "-1"
var selected_weapon: String = "-1"
var buying_tower: bool = false
var owned_weapons: Array[int] = [0, 0, 0, 0] # weapons are 1 when you own them
signal begin_buying(selected: String)
signal end_buying

# Objective health tracking
var objective_health: float = 500
var objective_max_health: float = 500
var objective_health_width: float

@onready var player: CharacterBody3D = %Player

var sword: PackedScene = preload("res://assets/weapons/Sword.tscn")
var bow: PackedScene = preload("res://assets/weapons/Bow.tscn")
var super_sword: PackedScene = preload("res://assets/weapons/Super_sword.tscn")
var crossbow: PackedScene = preload("res://assets/weapons/Crossbow.tscn")
var wooden_sword: PackedScene = preload("res://assets/weapons/Wooden Sword.tscn")

# Dictionary containing info for available towers.
# Info is accessed with tower_info[x][y] such that x is the dictionary key and y is the tower ID.
@export var tower_info: Dictionary = {
	# Name
	0: [
		"Crossbow Tower",
		"Cauldron Tower",
		"Ballista Tower",
		"Wall Tower"
	],
	# Health
	1: ["N/A", "N/A", "N/A", 100],
	# Damage
	2: [15, 4, 25, 0],
	# Speed
	3: [1.5, 4, 3.0, 0],
	# Description
	4: [
		"The crossbow tower fires arrows at the nearest enemy.",
		"The cauldron tower pours down boiling oil onto surrounding enemies.",
		"The ballista tower fires a piercing bolt at the furthest enemy.",
		"The wall tower blocks the path of enemies for a short time."
	],
	# Price
	5: [75, 200, 150, 100]
}

# Dictionary containing info for available weapons.
# Info is accessed with weapon_info[x][y] such that x is the dictionary key and y is the weapon ID.
@export var weapon_info: Dictionary = {
	# Name
	0: [
		"Sword",
		"Bow",
		"Super Sword",
		"Crossbow"
	],
	# Damage
	1: [10, 10, 20, 10],
	# Cooldown
	2: [0.33, 0.5, 0.25, 0.15],
	# Description
	3: [
		"You can use the sword to hit enemies up close.",
		"The bow can fire arrows at enemies from farther away.",
		"The can super use the super sword to super hit enemies up super close.",
		"The super bow can fire super arrows at super enemies from super farther away."
	],
	# Price
	4: [1, 10, 100, 1000]
}

func _get_price(i: int) -> int:
	return tower_info[5][i]

func _select_tower(i: String) -> void:
	if i == "-1":
		_reset_tower_values()
		buying_tower = false
		end_buying.emit()
	else:
		$LeftPanel/VBoxContainer/TowerVBox/Name.text = str(tower_info[0][int(i)])
		$LeftPanel/VBoxContainer/TowerVBox/MarginContainer/VBoxContainer/HealthBox/Health.text = str(tower_info[1][int(i)])
		$LeftPanel/VBoxContainer/TowerVBox/MarginContainer/VBoxContainer/DamageBox/Damage.text = str(tower_info[2][int(i)])
		$LeftPanel/VBoxContainer/TowerVBox/MarginContainer/VBoxContainer/SpeedBox/Speed.text = str(tower_info[3][int(i)])
		$LeftPanel/VBoxContainer/TowerVBox/Description.text = str(tower_info[4][int(i)])
		$LeftPanel/VBoxContainer/TowerVBox/Price/Label.text = str(tower_info[5][int(i)])
		_buying_tower()
		
func _select_weapon(i: String) -> void:
	if i == "-1":
		_reset_weapon_values()
		$LeftPanel/VBoxContainer/WeaponVBox/Equip.disabled = true
	else:
		$LeftPanel/VBoxContainer/WeaponVBox/Buy.disabled = false
		$LeftPanel/VBoxContainer/WeaponVBox/Equip.disabled = false
		$LeftPanel/VBoxContainer/WeaponVBox/Name.text = str(weapon_info[0][int(i)])
		$LeftPanel/VBoxContainer/WeaponVBox/MarginContainer/VBoxContainer/DamageBox/Damage.text = str(weapon_info[1][int(i)])
		$LeftPanel/VBoxContainer/WeaponVBox/MarginContainer/VBoxContainer/SpeedBox/Speed.text = str(weapon_info[2][int(i)])
		$LeftPanel/VBoxContainer/WeaponVBox/Description.text = str(weapon_info[3][int(i)])
		$LeftPanel/VBoxContainer/WeaponVBox/Price/Label.text = str(weapon_info[4][int(i)])
		
func _reset_tower_values() -> void:
	$LeftPanel/VBoxContainer/TowerVBox/Name.text = "No tower selected"
	$LeftPanel/VBoxContainer/TowerVBox/MarginContainer/VBoxContainer/HealthBox/Health.text = "N/A"
	$LeftPanel/VBoxContainer/TowerVBox/MarginContainer/VBoxContainer/DamageBox/Damage.text = "N/A"
	$LeftPanel/VBoxContainer/TowerVBox/MarginContainer/VBoxContainer/SpeedBox/Speed.text = "N/A"
	$LeftPanel/VBoxContainer/TowerVBox/Description.text = "Select a tower to see its statistics, description, and price."
	$LeftPanel/VBoxContainer/TowerVBox/Price/Label.text = "N/A"
	
func _reset_weapon_values() -> void:
	$LeftPanel/VBoxContainer/WeaponVBox/Buy.disabled = true
	$LeftPanel/VBoxContainer/WeaponVBox/Name.text = "No weapon selected"
	$LeftPanel/VBoxContainer/WeaponVBox/MarginContainer/VBoxContainer/DamageBox/Damage.text = "N/A"
	$LeftPanel/VBoxContainer/WeaponVBox/MarginContainer/VBoxContainer/SpeedBox/Speed.text = "N/A"
	$LeftPanel/VBoxContainer/WeaponVBox/Description.text = "Select a weapon to see its statistics, description, and price."
	$LeftPanel/VBoxContainer/WeaponVBox/Price/Label.text = "N/A"

func _ready() -> void:
	_reset_tower_values()
	_reset_weapon_values()

	# Initialize objective health bar
	await get_tree().process_frame
	objective_health_width = 320 # NOTE: Hard coded because it ended up being zero every time
	print("objective_health_width:")
	print(objective_health_width)
	# Connect to objective signals
	_connect_to_objective()

	_connect_to_spawnManager()
	
var t: float = 0.0

func _process(delta: float) -> void:
	t += delta
	
	# Update objective health bar
	if objective_health_width > 0:
		var health_percent: float = objective_health / objective_max_health
		$ObjectivePanel/VBoxContainer/ObjectiveHealthRect.size.x = objective_health_width * health_percent
		$ObjectivePanel/VBoxContainer/HBoxContainer/ObjectiveHealthLabel.text = str(int(objective_health), "/", int(objective_max_health), " ")
	# Update position of buying panel
	if buying_tower:
		$BuyingPanel.visible = true#position = $BuyingPanel.position.lerp(Vector2(389, 622), t)
	else:
		$BuyingPanel.visible = false#position = $BuyingPanel.position.lerp(Vector2(389, 722), t)

func _on_button_pressed() -> void:
	if button_group.get_pressed_button() == null:
		selected_tower = "-1"
	else:
		selected_tower = button_group.get_pressed_button().name
		
	_select_tower(selected_tower)

func _on_buy_pressed() -> void:
	var weapon_id: int = int(selected_weapon)
	var price: int = weapon_info[4][weapon_id]
	if $"../../GameManager".gold - price >= 0:
		$"../../GameManager"._change_gold(price * -1)
		print("You bought weapon " + selected_weapon)
		
		owned_weapons[weapon_id] = 1
		_check_for_weapon_own(weapon_id)
		
		$LeftPanel/VBoxContainer/WeaponVBox/Equip.text = "Equip"
		_on_equip_pressed()
	
func _buying_tower() -> void:
	$BuyingPanel/Label.text = str(str(tower_info[0][int(selected_tower)]), " is selected. Click on any valid area of the map to buy the tower. Select the tower again to cancel tower placement.")
	buying_tower = true
	begin_buying.emit(selected_tower)
	
func _connect_to_objective() -> void:
	# Find and connect to the objective in the scene
	var objectives := get_tree().get_nodes_in_group("objective")
	if objectives.size() > 0:
		var objective := objectives[0]
		objective_max_health = objective.get_max_health()
		objective_health = objective.get_health()
		print("2D HUD connected to objective")
	else:
		push_warning("2D HUD: No objective found in scene!")

func _connect_to_spawnManager() -> void:
	var spawn_managers := get_tree().get_nodes_in_group("spawnLibrary")
	if spawn_managers.size() > 0:
		library = spawn_managers[0]
		print("HUD Connected to spawn manager")
	else:
		push_warning("2D HUD: No spawn manager found in scene!")
		
func _update_next_level_text(next_level: int) -> void:
	$RightPanel/VBoxContainer/Label.text = str(next_level + 2)
	%"3dHud"._update_level_number(next_level + 2)
	
func _on_objective_damaged(current_health: float, max_health: float) -> void:
	objective_health = current_health
	objective_max_health = max_health

func _on_game_manager_end_buying() -> void:
	pass
	
func _on_game_manager_update_gold(value: Variant) -> void:
	$LeftPanel/VBoxContainer/GoldBox/Gold.text = str(value)

func _on_start_wave_pressed() -> void:
	$"../../GameManager"._toggle_mode()
	library.nextLevel()
	
# Update UI health on objective health change
func _on_objective_damaged_sig(_damage_taken: Variant, health_after_damage: Variant) -> void:
	objective_health = health_after_damage

# Switch between tower and weapon buying and vice versa
func _on_weapon_button_pressed() -> void:
	$LeftPanel/VBoxContainer/TowerVBox.visible = false
	$LeftPanel/VBoxContainer/WeaponVBox.visible = true

func _on_tower_button_pressed() -> void:
	$LeftPanel/VBoxContainer/TowerVBox.visible = true
	$LeftPanel/VBoxContainer/WeaponVBox.visible = false

func _on_weapon_selection_button_pressed() -> void:
	if weapon_button_group.get_pressed_button() == null:
		selected_weapon = "-1"
	else:
		selected_weapon = weapon_button_group.get_pressed_button().name
	
	print("You selected weapon ", selected_weapon)
	_check_for_weapon_own(int(selected_weapon))
	_select_weapon(selected_weapon)

func _on_equip_pressed() -> void:
	var this_weapon: Node3D
	
	if $LeftPanel/VBoxContainer/WeaponVBox/Equip.text == "Equip":
		match selected_weapon:
			"0":
				this_weapon = sword.instantiate()
				$LeftPanel/VBoxContainer/WeaponVBox/Equipped.text = "Currently equipped: Sword"
			"1":
				this_weapon = bow.instantiate()
				$LeftPanel/VBoxContainer/WeaponVBox/Equipped.text = "Currently equipped: Bow"
			"2":
				this_weapon = super_sword.instantiate()
				$LeftPanel/VBoxContainer/WeaponVBox/Equipped.text = "Currently equipped: Super Sword"
			"3":
				this_weapon = crossbow.instantiate()
				$LeftPanel/VBoxContainer/WeaponVBox/Equipped.text = "Currently equipped: Crossbow"
		$LeftPanel/VBoxContainer/WeaponVBox/Equip.text = "Unequip"
	else:
		this_weapon = wooden_sword.instantiate()
		$LeftPanel/VBoxContainer/WeaponVBox/Equipped.text = "Currently equipped: Wooden Sword"
		$LeftPanel/VBoxContainer/WeaponVBox/Equip.text = "Equip"
	
	player.equip_weapon(this_weapon)

# Hide buy button and show equip button if you select a weapon that you already have
func _check_for_weapon_own(id: int) -> void:
	if owned_weapons[id] == 1:
		$LeftPanel/VBoxContainer/WeaponVBox/Buy.visible = false
		$LeftPanel/VBoxContainer/WeaponVBox/Equip.visible = true
	else:
		$LeftPanel/VBoxContainer/WeaponVBox/Buy.visible = true
		$LeftPanel/VBoxContainer/WeaponVBox/Equip.visible = false
