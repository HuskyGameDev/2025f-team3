extends Node

signal damaged_sig(damage_taken, health_after_damage)
signal killed_sig

@export var max_health = 100
@export var health = 100

func take_damage(damage):
	health -= damage
	damaged_sig.emit(damage, health)
	if health <= 0:
		killed_sig.emit()
