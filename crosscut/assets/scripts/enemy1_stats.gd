extends CharacterBody3D

# just put variables that I can think of.
# let me know if there's more that need to be added or deleted.
@export var speed: float = 4
@export var rotation_speed: float = 5
@export var atk: float = 10
@export var atk_cooldown: int = 20 # how many frames between damage ticks

# exposing health node
@onready var health: Node3D = $Health

#array to hold bodies in contact with enemy
var in_contact_arr: Array[Node3D] = []

#flags for contact damage
var in_contact_player: bool = false
var in_contact_objective: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Test"):
		get_parent().get_node("SpawnLibrary").killedEnemy()
		queue_free()

# enemy attack based on cooldown
func _on_damage_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_contact_arr.append(body)
	elif body.is_in_group("objective"):
		in_contact_arr.append(body)

# detect player or objective leaving contact
func _on_damage_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_contact_arr.erase(body)
	elif body.is_in_group("objective"):
		in_contact_arr.erase(body)


# from down here, it is enemy movement
#@onready var player = get_parent().get_node("First-Person view").get_child(0)
@onready var obj: = get_parent().get_node("Objective").get_child(0)
const GRAVITY: int = -300

func _physics_process(delta:=) -> void:
	var direction: Vector3 = (obj.global_transform.origin - global_transform.origin)
	direction.y = 0
	var distance: float = direction.length()
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		move_and_slide()
	
	if distance > 0 && is_on_floor():
		var move_dir: Vector3 = direction.normalized()
		velocity = move_dir * speed
		move_and_slide()
	
		var target_rotation: = Vector3(0, atan2(move_dir.x, move_dir.z), 0)
		rotation.y = lerp_angle(rotation.y, target_rotation.y, rotation_speed * delta)
	else:
		velocity = Vector3.ZERO
		move_and_slide()
	
	#handle damaging player & objective
	if (Engine.get_physics_frames() % atk_cooldown == 0): #attack cooldown is based on delta % attack cooldown
		for body: Node3D in in_contact_arr:
			body.health.take_damage(atk)
			#await get_tree().create_timer(atk_cooldown).timeout

func _on_health_killed_sig() -> void:
	get_parent().get_node("SpawnLibrary").killedEnemy()
	queue_free()
