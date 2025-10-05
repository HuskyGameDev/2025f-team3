extends CharacterBody3D


@onready var grid_map = %GridMap
@onready var rigid_body_3d: RigidBody3D = $"../RigidBody3D"

# Movement variables
var speed = 0
const MAX_SPEED = 5.0
const ACCELERATION = 0.3
const DECELLERATION = 0.65 # Applied when no keys are pressed and on ground 

const JUMP_VELOCITY = 4.5

# Lookaround variables
var mouse_sensitivity = 0.002

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))
	
	#handle pausing the game
	if event.is_action_pressed("Pause"):
		if get_tree().paused == false:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().paused = true

func _physics_process(delta: float) -> void:
	print(grid_map.get_closest_position_on_grid(Vector2(position.x, position.z)))
	print(position)
	grid_map.add_tower(rigid_body_3d, Vector2(position.x, position.z))
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		grid_map.add_tower(rigid_body_3d, Vector2(position.x, position.z))

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		speed = clamp(speed+ACCELERATION, 0, MAX_SPEED)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	elif is_on_floor():
		velocity *= DECELLERATION
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)
	
	if direction.is_zero_approx():
		speed = clamp(speed-DECELLERATION, 0, MAX_SPEED)
	
	move_and_slide()
