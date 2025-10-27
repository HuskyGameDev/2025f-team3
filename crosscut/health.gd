extends Node

signal damage_taken(damage, health)
signal dead

@export var max_health = 100
@export var health = 100

func take_damage(damage):
	health -= damage
	damage_taken.emit(damage, health)
	if health <= 0:
		dead.emit()
