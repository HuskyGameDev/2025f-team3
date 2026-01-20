extends CharacterBody3D

# just put variables that I can think of.
# let me know if there's more that need to be added or deleted.
@export var  speed: int = 4
@export var rotation_speed: int = 5
@export var atk: int = 10
@export var atk_speed: int = 5

# exposing health node
@onready var health: Node3D = $Health

# exposing objective node 
#@onready var objective = %Objective #TODO: FIX THIS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Test"):
		get_parent().get_node("SpawnLibrary").killedEnemy()
		queue_free()

# enemy attack, currently only deal damage when collide with the player
func _on_damage_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.health.take_damage(atk)
	elif body.is_in_group("objective"): #TODO: Fix objective not taking damage from enemies
		body.health.take_damage(atk)

# from down here, it is enemy movement
#@onready var player = get_parent().get_node("First-Person view").get_child(0)
@onready var obj: Node3D = get_parent().get_node("Objective").get_child(0)
const GRAVITY = -300

func _physics_process(delta: float) -> void:
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
	
		var target_rotation: Vector3 = Vector3(0, atan2(move_dir.x, move_dir.z), 0)
		rotation.y = lerp_angle(rotation.y, target_rotation.y, rotation_speed * delta)
	else:
		velocity = Vector3.ZERO
		move_and_slide()

func _on_health_killed_sig() -> void:
	get_parent().get_node("SpawnLibrary").killedEnemy()
	queue_free()
