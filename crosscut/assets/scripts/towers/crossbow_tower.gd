extends StaticBody3D

const debug = false
var tower_lookaround_time_range = Vector2(1, 2)
var tower_look_desired = Vector3(0, 0, 0)
var tower_turnspeed = 4

var state: CrossbowState
enum CrossbowState {IDLE, TRACKING}

@onready var tower_head: Node3D = $TowerHead
@onready var idle_lookaround_timer: Timer = $IdleLookaroundTimer
@onready var firing_timer: Timer = $FiringTimer
@onready var player: CharacterBody3D = %Player
@onready var attack_area: Area3D = $AttackArea

var crossbow_bolt = preload("res://assets/scenes/projectiles/crossbow_bolt.tscn")


func _ready() -> void:
	_transition_to_idle_state()
	
func _process(delta: float) -> void:
	if state == CrossbowState.IDLE:
		_idle_state()
	elif state == CrossbowState.TRACKING:
		_tracking_state()
	
	# Always turn towards desired look position
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
	
	tower_look_desired = position.direction_to(first_seen_enemy.position)

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
	new_bolt.position = tower_head.position
	new_bolt.target = bolt_target
	new_bolt.reparent(get_tree().root.get_child(0))
	print(get_tree().root.get_child(0).name)
	print("firing bolt")
	
func _get_target():
	# Easily could implement bloons-type targeting (closest to tower, closest to base, etc)
	return attack_area.get_overlapping_bodies().filter(func(b:Node3D): return b.is_in_group("enemy")).front()
