extends CharacterBody3D

# just put variables that I can think of.
# let me know if there's more that need to be added or deleted.
@export var hp = 10
@export var speed = 4
@export var rotation_speed = 5
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


func _on_area_3d_body_entered(body: Node3D) -> void:
		if body.is_in_group("player"):
		body.take_damage(atk)

# from down here, it is enemy movement
@onready var player = %Player

func _physics_process(delta):
		var direction = (player.global_transform.origin - global_transform.origin)
		direction.y = 0
		var distance = direction.length()

		if distance > 0:
			var move_dir = direction.normalized()
			velocity = move_dir * speed
			move_and_slide()

			var target_rotation = Vector3(0, atan2(move_dir.x, move_dir.z), 0)
			rotation.y = lerp_angle(rotation.y, target_rotation.y, rotation_speed * delta)
		else:
			velocity = Vector3.ZERO
			move_and_slide()
