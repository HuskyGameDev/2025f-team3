extends Node

signal damaged_sig(damage_taken, health_after_damage)
signal killed_sig

@export var max_health = 100
@export var health = 100

func take_damage(damage):
	health -= damage
	damaged_sig.emit(damage, health)
	print("Health after damage: ", health, " (max: ", max_health, ")")
	if health <= 0:
		print("HEALTH ZERO - EMITTING KILLED SIGNAL for: ", get_parent().name)
		killed_sig.emit()
