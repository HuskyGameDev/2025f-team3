extends CharacterBody3D

@export var speed: float = 1
@export var rotation_speed: float = 3
@export var atk: float = 30
@export var atk_cooldown: int = 30 # how many frames between damage ticks
@export var max_health: int = 200

# exposing health node
@onready var health: Node3D = $Health
@onready var obj: Node3D = get_tree().get_nodes_in_group("objective").front() #TODO: make this pick just the objective

#array to hold bodies in contact with enemy
var in_contact_arr: Array[Node3D] = []

#flags for contact damage
var in_contact_player: bool = false
var in_contact_objective: bool = false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var target_pos: Vector3
var has_target: bool = false
func _ready() -> void:
	has_target = true
	target_pos = obj.position
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

const GRAVITY: int = -300

func _physics_process(delta:=) -> void:
	if has_target:
		nav_agent.target_position = target_pos
		var next_path_pos := nav_agent.get_next_path_position()
		var direction := global_position.direction_to(next_path_pos)
		velocity = direction * speed
		
		var ROTATION_SPEED: float = rotation_speed
		var target_rotation := direction.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
		if abs(target_rotation - rotation.y) > deg_to_rad(60):
			ROTATION_SPEED = 20
		rotation.y = move_toward(rotation.y, target_rotation, delta * ROTATION_SPEED)
		
	move_and_slide()
	
	if (Engine.get_physics_frames() % atk_cooldown == 0): #attack cooldown is based on delta % attack cooldown
		for body: Node3D in in_contact_arr:
			body.health.take_damage(atk)

func _on_health_killed_sig() -> void:
	AudioManager.play_sfx("goblin_death")
	get_parent().get_node("SpawnLibrary").killedEnemy()
	queue_free()
