extends StaticBody3D

const debug = false

# Attack settings
@export var damage = 10
@export var firing_speed = 6
# NOTE: Attack radius can be adjusted with the attack area node child

# Runtime variables
var state: CauldronState
enum CauldronState {IDLE, SPLASHING}

# Local References
@onready var firing_timer: Timer = $FiringTimer
@onready var player: CharacterBody3D = %Player
@onready var attack_area: Area3D = $AttackArea
@onready var splash_source: Node3D = $SplashSource

# Crossbow bolt packed scene
var cauldron_splash = preload("res://assets/scenes/projectiles/cauldron_splash.tscn")

func _ready() -> void:
	set_firing_speed(firing_speed)
	_transition_to_idle_state()
	
func _process(delta: float) -> void:
	if state == CauldronState.IDLE:
		_idle_state()
	elif state == CauldronState.SPLASHING:
		_splashing_state()
	
# Idle state:
func _transition_to_idle_state():
	state = CauldronState.IDLE

func _idle_state():
	var first_seen_enemy = _get_target()
	if first_seen_enemy:
		_transition_to_splashing_state()

# Splashing state:
func _transition_to_splashing_state():
	state = CauldronState.SPLASHING
	_splash()
	firing_timer.start()

	
func _splashing_state():
	pass
	

func _on_firing_timer_timeout() -> void:
	if state != CauldronState.SPLASHING: return
	_transition_to_idle_state()

# Getters and setters
func set_firing_speed(new_value):
	firing_timer.wait_time = new_value

# Non-state-specific functions
func _splash():
	print("splashing")
	var new_splash = cauldron_splash.instantiate()
	new_splash.transform = splash_source.transform
	new_splash.damage = damage
	add_child(new_splash)

func _get_target():
	# Easily could implement bloons-type targeting (closest to tower, closest to base, etc)
	var enemies = attack_area.get_overlapping_bodies().filter(func(b:Node3D): return b.is_in_group("enemy"))
	if enemies.is_empty():
		return null
	return enemies.front()
