extends CharacterBody3D

signal objective_damaged(current_health, max_health)
signal objective_destroyed

@onready var grid_map = %GridMap

# Exposing child health node to other scripts
@onready var health: Node3D = $Health
@export var max_health = 500

func _ready() -> void:
	# Setup health component
	if health:
		health.max_health = max_health
		health.health = max_health
		health.damaged_sig.connect(_on_damage_taken)
		health.killed_sig.connect(_on_dead)
	else:
		push_error("Objective: Health component not found!")


func _on_damage_taken(amount: float) -> void:
	# Called when objective takes damage
	if health:
		objective_damaged.emit(health.health, health.max_health)
		print("Objective damaged! Health: %d/%d" % [health.health, health.max_health])

func _on_dead() -> void:
	# Called when objective is destroyed
	objective_destroyed.emit()
	print("OBJECTIVE DESTROYED - GAME OVER!")
	# Could add effects, animations, etc. here
	# For now, just keep it visible but mark as destroyed

func get_health() -> float:
	# Returns current health - useful for UI
	return health.health

func get_max_health() -> float:
	# Returns max health - useful for UI
	return health.max_health
