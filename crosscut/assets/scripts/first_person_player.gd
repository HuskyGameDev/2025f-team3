extends CharacterBody3D

@export var max_hp = 100
@export var hp = 100
@export var atk = 10
@export var atk_speed = 5

func take_damage(damage):
	hp -= damage
	damage_sig.emit(damage, hp)
	if hp <= 0:
		dead_sig.emit()
		destroy()

func destroy():
	queue_free()
	# need a reviving script

@onready var grid_map = %GridMap

var crossbow_tower = preload("res://assets/scenes/towers/crossbow_tower.tscn")

signal damage_sig(damage, hp)
signal dead_sig

var disabled = false

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
	if disabled: 
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$PlayerCam.rotate_x(-event.relative.y * mouse_sensitivity)
		$PlayerCam.rotation.x = clampf($PlayerCam.rotation.x, -deg_to_rad(70), deg_to_rad(70))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if disabled:
		return

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("ui_text_scroll_up"):
		grid_map.add_tower(crossbow_tower, global_position)
		
	if Input.is_action_just_pressed("ui_text_scroll_down"):
		grid_map.remove_tower_at_position(global_position)

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
	
	if direction.is_zero_approx():
		speed = clamp(speed-DECELLERATION, 0, MAX_SPEED)
	
	move_and_slide()
	
