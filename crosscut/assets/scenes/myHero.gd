extends CharacterBody3D

# just put variables that I can think of.
# let me know if there's more that need to be added or deleted.
@export var speed: float = 0 #was 4
@export var rotation_speed: float = 5
@export var atk: float = 0

# exposing health node
@onready var health: Node3D = $Health
@onready var obj: Node3D = get_tree().get_nodes_in_group("objective").front() #TODO: make this pick just the objective

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var target_pos: Vector3
var has_target: bool = false
func _ready() -> void:
	has_target = true
	target_pos = obj.position


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
	
