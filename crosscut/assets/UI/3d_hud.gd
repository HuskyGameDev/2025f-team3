extends CanvasLayer

var time_elapsed: float = 0
var health: float = 100
var health_width: float
var max_health: float = 100
var enemies_killed: int
var enemies_left: int

# Objective health tracking
var objective_health: float = 500
var objective_max_health: float = 500
var objective_health_width: float

func _ready() -> void:
	# health_width assignment doesn't occur unless we await
	await get_tree().process_frame
	health_width = $HealthPanel/VBoxContainer/HealthRect.size.x
	objective_health_width = $ObjectivePanel/VBoxContainer/ObjectiveHealthRect.size.x

	# Connect to objective signals
	_connect_to_objective()

func _process(delta: float) -> void:
	time_elapsed += delta

	# Calculate and display time to HUD
	var seconds: float = snapped(fmod(time_elapsed, 60), 0.01)
	var minutes: int = floor(time_elapsed / 60)
	var time: String = str(str("%02d" % snapped(minutes, 1)), ":", str("%05.2f" % seconds))
	$TimePanel/HBoxContainer/Time2.text = time

	# Update player health bar
	$HealthPanel/VBoxContainer/HealthRect.size.x = health_width - ((100 + (health * -1)) / 100) * health_width
	$HealthPanel/VBoxContainer/HBoxContainer/HealthLabel.text = str(int(health), "/", int(max_health), " ")

	$EnemyPanel/VBoxContainer/HBoxContainer/EnemiesKilled.text = str(enemies_killed, " ")
	$EnemyPanel/VBoxContainer/HBoxContainer/TotalEnemies.text = str("/ ", enemies_left)
	# Update objective health bar
	if objective_health_width > 0:
		var health_percent: float = objective_health / objective_max_health
		$ObjectivePanel/VBoxContainer/ObjectiveHealthRect.size.x = objective_health_width * health_percent
		$ObjectivePanel/VBoxContainer/HBoxContainer/ObjectiveHealthLabel.text = str(int(objective_health), "/", int(objective_max_health), " ")

func _update_health(value: int) -> void:
	health = value

func _update_enemies_killed(value: int) -> void:
	enemies_killed = value

func _update_enemies_left(value: int) -> void:
	enemies_left = value
	
func _update_wave_number(value: int) -> void:
	$WavePanel/VBoxContainer/Wave.text = str(value)
	
func _update_level_number(value: int) -> void:
	$WavePanel/VBoxContainer/Level.text = str(value)

func _connect_to_objective() -> void:
	# Find and connect to the objective in the scene
	var objectives: Array = get_tree().get_nodes_in_group("objective")
	if objectives.size() > 0:
		var objective: Node = objectives[0]
		objective_max_health = objective.get_max_health()
		objective_health = objective.get_health()
		print("3D HUD connected to objective")
	else:
		push_warning("3D HUD: No objective found in scene!")

func _on_health_damaged_sig(_damage_taken: Variant, current_health: Variant) -> void:
	health = current_health

# Update UI health on objective health change
func _on_objective_damaged_sig(_damage_taken: Variant, health_after_damage: Variant) -> void:
	objective_health = health_after_damage

func _on_game_manager_player_died() -> void:
	$DeadLabel.visible = true

func _on_game_manager_player_revived() -> void:
	$DeadLabel.visible = false
	health = max_health
