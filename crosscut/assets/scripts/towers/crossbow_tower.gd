extends StaticBody3D

const debug = false

# Behavior settings
var tower_lookaround_time_range = Vector2(1, 2) # The range of time intervals when looking around randomly
var tower_turnspeed = 4 # How quickly the tower turns to where it wants to look

# Attack settings
var damage = 10
var firing_speed = 1

# Runtime variables
var tower_look_desired = Vector3(0, 0, 0)
var state: CrossbowState
enum CrossbowState {IDLE, TRACKING}



# Local References
@onready var tower_head: Node3D = $TowerHead
@onready var idle_lookaround_timer: Timer = $IdleLookaroundTimer
@onready var firing_timer: Timer = $FiringTimer
@onready var player: CharacterBody3D = %Player
@onready var attack_area: Area3D = $AttackArea

# Crossbow bolt packed scene
var crossbow_bolt = preload("res://assets/scenes/projectiles/crossbow_bolt.tscn")


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
	var look_direction = Basis.looking_at(tower_look_desired.normalized())
	tower_head.transform.basis = tower_head.transform.basis.slerp(look_direction, tower_turnspeed*delta)

# Idle state:
#	Maybe look around in random directions every couple seconds
func _transition_to_idle_state():
	state = CrossbowState.IDLE

func _idle_state():
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
func _transition_to_tracking_state():
	state = CrossbowState.TRACKING
	firing_timer.start()
	
func _tracking_state():
	var first_seen_enemy = _get_target()
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
func set_firing_speed(new_value):
	firing_timer.wait_time = new_value

# Non-state-specific functions
func _fire_bolt(bolt_target: Node3D):
	var new_bolt = crossbow_bolt.instantiate()
	new_bolt.transform = tower_head.transform
	new_bolt.target = bolt_target
	new_bolt.damage = damage
	add_child(new_bolt)

func _get_target():
	# Easily could implement bloons-type targeting (closest to tower, closest to base, etc)
	var enemies = attack_area.get_overlapping_bodies().filter(func(b:Node3D): return b.is_in_group("enemy"))
	if enemies.is_empty():
		return null
	return enemies.front()
