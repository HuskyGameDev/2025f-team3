extends StaticBody3D

const debug = false

# Behavior settings
@export var tower_lookaround_time_range: Vector2 = Vector2(1, 2) # The range of time intervals when looking around randomly
@export var tower_turnspeed: float = 4 # How quickly the tower turns to where it wants to look

# Attack settings
@export var damage: float = 10
@export var firing_speed: float = 1
# NOTE: Attack radius can be adjusted with the attack area node child

# Runtime variables
var tower_look_desired: Vector3 = Vector3(0, 0, 0)
var state: CrossbowState
enum CrossbowState {IDLE, TRACKING}



# Local References
@onready var tower_head: Node3D = $TowerHead
@onready var idle_lookaround_timer: Timer = $IdleLookaroundTimer
@onready var firing_timer: Timer = $FiringTimer
@onready var player: CharacterBody3D = %Player
@onready var attack_area: Area3D = $AttackArea

# Crossbow bolt packed scene
var crossbow_bolt: PackedScene = preload("res://assets/scenes/projectiles/crossbow_bolt.tscn")


func _ready() -> void:
	set_firing_speed(firing_speed)
	_transition_to_idle_state()
	
func _process(delta: float) -> void:
	if state == CrossbowState.IDLE:
		_idle_state()
	elif state == CrossbowState.TRACKING:
		_tracking_state()
	
	# Always turn towards desired look position
	if (tower_look_desired.normalized().is_zero_approx()):
		return
	var look_direction: Basis = Basis.looking_at(tower_look_desired.normalized())
	tower_head.transform.basis = tower_head.transform.basis.slerp(look_direction, tower_turnspeed*delta)

# Idle state:
#	Maybe look around in random directions every couple seconds
func _transition_to_idle_state() -> void:
	state = CrossbowState.IDLE

func _idle_state() -> void:
	# Idle state can be empty for now since everything is signal-based
	pass
	
func _on_idle_lookaround_timer_timeout() -> void:
	if state != CrossbowState.IDLE: return
	
	# Transition if enemy is in range
	if _get_target():
		_transition_to_tracking_state()
		return
	
	# Look at random spot
	tower_look_desired = Vector3(randf_range(-1, 1), -0.3, randf_range(-1,1))
	# Set new random timer value
	idle_lookaround_timer.wait_time = randf_range(tower_lookaround_time_range.x, tower_lookaround_time_range.y)
		

# Tracking state:
# 	Constantly look at the enemy and fire every few seconds
func _transition_to_tracking_state() -> void:
	state = CrossbowState.TRACKING
	firing_timer.start()
	
func _tracking_state() -> void:
	var first_seen_enemy: Node3D = _get_target()
	if !first_seen_enemy:
		if debug: print("No tower target, transitioning to idle")
		_transition_to_idle_state()
		return
	
	if debug: print("Target seen")
	
	tower_look_desired = tower_head.global_position.direction_to(first_seen_enemy.global_position)

func _on_firing_timer_timeout() -> void:
	if state != CrossbowState.TRACKING: return
	_fire_bolt(_get_target())
	firing_timer.start()


# Getters and setters
func set_firing_speed(new_value: float) -> void:
	firing_timer.wait_time = new_value

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Non-state-specific functions
func _fire_bolt(bolt_target: Node3D) -> void:
	var new_bolt: Node3D = crossbow_bolt.instantiate()
	new_bolt.transform = tower_head.transform
	new_bolt.target = bolt_target
	new_bolt.damage = damage
	add_child(new_bolt)
	# Play one of three random sounds.
	var sound: int = rng.randi_range(1, 3)
	if sound == 1: 
		var CrossbowSound: AudioStreamPlayer3D = get_node("CrossbowSound1")
		CrossbowSound.play();
	elif sound == 2:
		var CrossbowSound: AudioStreamPlayer3D = get_node("CrossbowSound2")
		CrossbowSound.play();
	elif sound == 3:
		var CrossbowSound: AudioStreamPlayer3D = get_node("CrossbowSound3")
		CrossbowSound.play();
	else:
		pass
	

func _get_target() -> Node3D:
	# Easily could implement bloons-type targeting (closest to tower, closest to base, etc)
	var enemies: Array[Node3D] = attack_area.get_overlapping_bodies().filter(func(b:Node3D)->bool: return b.is_in_group("enemy"))
	if enemies.is_empty():
		return null
	return enemies.front()
