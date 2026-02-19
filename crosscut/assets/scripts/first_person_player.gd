extends CharacterBody3D

@onready var grid_map: Node3D = %GridMap


# Exposing child health node to other scripts
@onready var health: Node3D = $Health

# Just here for spawning towers at player pos with keys. Keeping here for testing.
#var crossbow_tower = preload("res://assets/scenes/towers/crossbow_tower.tscn")

# For first person weapon, current default weapon
@export var weapon_scene: PackedScene = preload("res://assets/scenes/Weapon.tscn")

@export var starting_weapon: GameWeaponData = preload("res://assets/weapons/sword.tres")

@export var in_round: bool = false

@onready var weapon_socket: Node3D = $WeaponSocket

var equipped_weapon: Weapon = null

var disabled: bool = false

# Movement variables
var speed: float = 0
const MAX_SPEED: float = 5.0
const ACCELERATION: float = 0.3
const DECELLERATION: float = 0.65 # Applied when no keys are pressed and on ground 

const JUMP_VELOCITY: float = 4.5

# Lookaround variables
var mouse_sensitivity: float = 0.002

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	

	
func _input(event: InputEvent) -> void:
	if disabled: 
		return
	
	if in_round and event.is_action_pressed("Attack") and equipped_weapon != null:
		var origin: Vector3 = global_position + Vector3(0, 1.0, 0)
		var dir: Vector3 = -global_transform.basis.z
		
		# Mainly for testing
		equipped_weapon.try_fire(origin, dir)
		print("ATTACK TEST fired")

	
	#if event is InputEventKey and event.pressed:
	#	print("Key pressed:", event.keycode)
	
	
		
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
	
	#if Input.is_action_just_pressed("ui_text_scroll_up"):
		#grid_map.add_tower(crossbow_tower, global_position)
		#
	#if Input.is_action_just_pressed("ui_text_scroll_down"):
		#grid_map.remove_tower_at_position(global_position)

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
	



func equip_weapon(new_data: GameWeaponData) -> void:
	# If something is equipped, replace it (or just return if you never swap)
	if equipped_weapon != null:
		
		weapon_socket.remove_child(equipped_weapon)
		
		equipped_weapon.queue_free()
		
		equipped_weapon = null

	var inst: Node = weapon_scene.instantiate()
	
	var w: Weapon = inst as Weapon
	
	if w == null:
		
		push_error("weapon_scene does not instance a Weapon node.")
		
		return

	weapon_socket.add_child(w)
	
	w.transform = Transform3D.IDENTITY
	
	w.data = new_data
	
	equipped_weapon = w

func ensure_equipped() -> void:
	
	if equipped_weapon == null:
		
		equip_weapon(starting_weapon)
