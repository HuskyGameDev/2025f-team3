extends Node

signal damaged_sig(damage_taken: int, health_after_damage: int)
signal killed_sig

@export var debug: bool = false
@export var max_health: int
@export var hitFX: GPUParticles3D #assigned as child in editor

@onready var health: float = max_health

func restore_health() -> void:
	health = max_health

func take_damage(damage: int) -> void:
	if debug: print("Current health is ", health)
	health -= damage
	damaged_sig.emit(damage, health)
	hitFX.restart() #display hit particle FX
	if debug: print("Health after damage: ", health, " (max: ", max_health, ")")
	if health <= 0:
		if debug: print("HEALTH ZERO - EMITTING KILLED SIGNAL for: ", get_parent().name)
		killed_sig.emit()
