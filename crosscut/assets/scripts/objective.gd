extends Node3D
class_name Objective

# Signals for game manager and UI
signal objective_damaged(current_health, max_health)
signal objective_destroyed

# Export variables for designer tweaking
@export var max_health = 500
@export var visual_scale = 1.0
@export var group_name = "objective"

# Reference to health component
@onready var health_component = $Health

func _ready():
	# Add to global group for easy reference by enemies
	add_to_group(group_name)

	# Setup health component
	if health_component:
		health_component.max_health = max_health
		health_component.damage_taken.connect(_on_damage_taken)
		health_component.dead.connect(_on_dead)
	else:
		push_error("Objective: Health component not found!")

	# Apply visual scale if mesh exists
	if has_node("MeshInstance3D"):
		$MeshInstance3D.scale = Vector3.ONE * visual_scale

	print("Objective initialized with %d HP at position %s" % [max_health, global_position])

func _on_damage_taken(amount):
	# Called when objective takes damage
	if health_component:
		objective_damaged.emit(health_component.current_health, health_component.max_health)
		print("Objective damaged! Health: %d/%d" % [health_component.current_health, health_component.max_health])

func _on_dead():
	# Called when objective is destroyed
	objective_destroyed.emit()
	print("OBJECTIVE DESTROYED - GAME OVER!")
	# Could add effects, animations, etc. here
	# For now, just keep it visible but mark as destroyed

func get_health():
	# Returns current health - useful for UI
	if health_component:
		return health_component.current_health
	return 0

func get_max_health():
	# Returns max health - useful for UI
	return max_health

func take_damage(amount):
	# Public method to damage the objective
	if health_component:
		health_component.take_damage(amount)
