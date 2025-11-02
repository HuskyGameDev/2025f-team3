extends CharacterBody3D

# just put variables that I can think of.
# let me know if there's more that need to be added or deleted.
@export var hp = 10
@export var speed = 4
@export var rotation_speed = 5
@export var atk = 10
@export var atk_speed = 5


func take_damage(damage : int):
	hp = hp - damage
	if hp <= 0:
		get_parent().get_node("SpawnLibrary").killedEnemy()
		destroy()

func destroy():
	queue_free()

func _input(event):
	if event.is_action_pressed("Test"):
		print("KILLING ENEMY")
		get_parent().get_node("SpawnLibrary").killedEnemy()
		destroy()

# enemy attack, currently only deal damage when collide with the player
func _on_damage_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.health.take_damage(atk)

# from down here, it is enemy movement
@onready var player = get_parent().get_node("First-Person view").get_child(0)

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
