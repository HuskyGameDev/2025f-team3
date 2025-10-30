extends CanvasLayer

var time_elapsed = 0
var health: float = 100
var health_width
var enemies_killed
var enemies_left

# Objective health tracking
var objective_health: float = 500
var objective_max_health: float = 500
var objective_health_width

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
	var seconds = snapped(fmod(time_elapsed, 60), 0.01)
	var minutes = floor(time_elapsed / 60)
	var time = str(str("%02d" % snapped(minutes, 1)), ":", str("%05.2f" % seconds))
	$TimePanel/HBoxContainer/Time2.text = time

	# Update player health bar
	$HealthPanel/VBoxContainer/HealthRect.size.x = health_width - ((100 + (health * -1)) / 100) * health_width

	# Update objective health bar
	if objective_health_width > 0:
		var health_percent = objective_health / objective_max_health
		$ObjectivePanel/VBoxContainer/ObjectiveHealthRect.size.x = objective_health_width * health_percent
		$ObjectivePanel/VBoxContainer/HBoxContainer/ObjectiveHealthLabel.text = str(int(objective_health), "/", int(objective_max_health))
	
func _update_health(value):
	health_width = value

func _update_enemies_killed(value):
	enemies_killed = value

func _update_enemies_left(value):
	enemies_left = value

func _on_player_damage_sig(damage_taken, current_health) -> void:
	health = current_health
	print(health)

func _connect_to_objective() -> void:
	# Find and connect to the objective in the scene
	var objectives = get_tree().get_nodes_in_group("objective")
	if objectives.size() > 0:
		var objective = objectives[0]
		objective_max_health = objective.get_max_health()
		objective_health = objective.get_health()
		objective.objective_damaged.connect(_on_objective_damaged)
		print("3D HUD connected to objective")
	else:
		push_warning("3D HUD: No objective found in scene!")

func _on_objective_damaged(current_health: float, max_health: float) -> void:
	objective_health = current_health
	objective_max_health = max_health
