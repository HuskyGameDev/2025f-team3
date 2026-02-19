extends Node

signal damaged_sig(damage_taken: int, health_after_damage: int)
signal killed_sig

@export var debug: bool = false
@export var max_health: int

@onready var health: float = max_health

func restore_health() -> void:
	health = max_health

func take_damage(damage: int) -> void:
	print("Current health is ", health)
	health = maxf(health - damage, 0)
	damaged_sig.emit(damage, health)
	print("Health after damage: ", health, " (max: ", max_health, ")")
	if health <= 0:
		if debug: print("HEALTH ZERO - EMITTING KILLED SIGNAL for: ", get_parent().name)
		killed_sig.emit()
