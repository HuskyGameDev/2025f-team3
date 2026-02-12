extends StaticBody3D
class_name Tower

const debug = false

# Health Settings
@export var maxHealth: float = 20 
@onready var Health: float = maxHealth

# Attack settings
@export var damage: float = 10
@export var firing_speed: float = 1
# NOTE: Attack radius can be adjusted with the attack area node child

# Runtime variables
var state: TowerState
enum TowerState {IDLE, Active}

# Local References
@onready var tower_head: Node3D = $TowerHead
@onready var idle_lookaround_timer: Timer = $IdleLookaroundTimer
@onready var firing_timer: Timer = $FiringTimer
@onready var player: CharacterBody3D = get_tree().current_scene.find_child("Player")
@onready var objective: Node3D = get_tree().current_scene.find_child("Objective")
@onready var attack_area: Area3D = $AttackArea

# Attack packed scene
@export var tower_Attack_Visual: PackedScene


func _ready() -> void:
	set_firing_speed(firing_speed)
	_transition_to_idle_state()

func _process(_delta: float) -> void:
	if state == TowerState.IDLE:
		_idle_state()
	elif state == TowerState.Active:
		_active_state()

# Idle state:
func _transition_to_idle_state() -> void:
	state = TowerState.IDLE

func _idle_state() -> void:
	pass

# Active state:
func _transition_to_Active_state() -> void:
	state = TowerState.Active
	firing_timer.start()

func _active_state() -> void:
	if debug: print("Tower is Active")

# Getters and setters
func set_firing_speed(new_value: float) -> void:
	firing_timer.wait_time = new_value

func take_damage(_damage: float) -> void:
	Health-=_damage
	if(Health<=0):
		queue_free()

func repair() -> void:
	Health += maxHealth * 0.5 
