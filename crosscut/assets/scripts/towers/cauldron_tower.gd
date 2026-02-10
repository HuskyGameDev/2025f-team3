extends StaticBody3D

const debug = false

# Attack settings
@export var damage: int = 10
@export var firing_speed: int = 6

# This tower's splash radius is taken from the sight radius + this variable
@export var splash_radius_vision_offset: float

# Runtime variables
var state: CauldronState
enum CauldronState {IDLE, SPLASHING}

# Local References
@onready var firing_timer: Timer = $FiringTimer
#@onready var player: CharacterBody3D = %Player
@onready var player: CharacterBody3D = get_tree().get_nodes_in_group("player").front()
@onready var attack_area: Area3D = $AttackArea
@onready var splash_source: Node3D = $SplashSource
@onready var attack_shape: CollisionShape3D = $AttackArea/AttackShape

# Crossbow bolt packed scene
var cauldron_splash: = preload("res://assets/scenes/projectiles/cauldron_splash.tscn")

func _ready() -> void:
	set_firing_speed(firing_speed)
	_transition_to_idle_state()
	
func _process(delta: float) -> void:
	if state == CauldronState.IDLE:
		_idle_state()
	elif state == CauldronState.SPLASHING:
		_splashing_state()
	
# Idle state:
func _transition_to_idle_state() -> void:
	state = CauldronState.IDLE

func _idle_state() -> void:
	var first_seen_enemy: = _get_target()
	if first_seen_enemy:
		_transition_to_splashing_state()

# Splashing state:
func _transition_to_splashing_state() -> void:
	state = CauldronState.SPLASHING
	_splash()
	firing_timer.start()

	
func _splashing_state() -> void:
	pass
	

func _on_firing_timer_timeout() -> void:
	if state != CauldronState.SPLASHING: return
	_transition_to_idle_state()

# Getters and setters
func set_firing_speed(new_value: int) -> void:
	firing_timer.wait_time = new_value

# Non-state-specific functions
func _splash() -> void:
	# print("splashing")
	var new_splash: = cauldron_splash.instantiate()
	new_splash.transform = splash_source.transform
	new_splash.damage = damage
	new_splash.splash_radius = splash_radius_vision_offset+attack_shape.scale.x
	add_child(new_splash)

func _get_target() -> Node3D:
	# Easily could implement bloons-type targeting (closest to tower, closest to base, etc)
	var enemies: Array[Node3D] = attack_area.get_overlapping_bodies().filter(func(b:Node3D) -> bool: return b.is_in_group("enemy"))
	if enemies.is_empty():
		return null
	return enemies.front()
