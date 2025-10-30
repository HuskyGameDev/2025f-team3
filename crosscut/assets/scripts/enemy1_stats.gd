extends CharacterBody3D

# just put variables that I can think of.
# let me know if there's more that need to be added or deleted.
@export var hp = 10
@export var speed = 10
@export var atk = 10
@export var atk_speed = 5

"""
func towerDamage(damage : int):
	hp = hp - damage
	if hp <= 0:
		destroy()
"""
func destroy():
	queue_free()

func _input(event):
	if event.is_action_pressed("Test"):
		get_parent().get_node("SpawnLibrary").killedEnemy()
		print("KILLING ENEMY")
		destroy()
