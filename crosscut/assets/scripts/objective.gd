extends CharacterBody3D

signal objective_damaged(damage_taken: int, health_after_damage: int, max_health: int)
signal objective_destroyed

@onready var grid_map: Node3D = %GridMap

# Exposing child health node to other scripts
@onready var health: Node3D = $Health
@export var max_health: int = 500

func _ready() -> void:
	# Setup health component
	if health:
		health.max_health = max_health
		health.health = max_health
	else:
		push_error("Objective: Health component not found!")
		
func _process(delta: float) -> void:
	if health.health <= 0:
		objective_destroyed.emit()
		health.health = 1 # To prevent an infinite loop

func get_health() -> float:
	# Returns current health - useful for UI
	return health.health

func get_max_health() -> float:
	# Returns max health - useful for UI
	return health.max_health
