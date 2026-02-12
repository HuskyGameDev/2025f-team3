extends Tower

#TODO: Rename to Projectile Tower


# Behavior settings
@export var tower_lookaround_time_range: Vector2 = Vector2(1, 2) # The range of time intervals when looking around randomly
@export var tower_turnspeed: float = 4 # How quickly the tower turns to where it wants to look
@export var targeting: TargetType = TargetType.Objective
enum TargetType {Close, Far, Objective, Player}

# Runtime variables
var tower_look_desired: Vector3 = Vector3(0, 0, 0)

# Local References
# Look to TowerBase for baseline references


func _process(_delta: float) -> void:
	super(_delta)
	
	# Always turn towards desired look position
	if (tower_look_desired.normalized().is_zero_approx()):
		return
	var look_direction: Basis = Basis.looking_at(tower_look_desired.normalized())
	tower_head.transform.basis = tower_head.transform.basis.slerp(look_direction, tower_turnspeed*_delta)

# Idle state:
#	Maybe look around in random directions every couple seconds
func _on_idle_lookaround_timer_timeout() -> void:
	if state != TowerState.IDLE: return
	
	# Transition if enemy is in range
	if _get_target():
		_transition_to_Active_state()
		return
	
	# Look at random spot
	tower_look_desired = Vector3(randf_range(-1, 1), -0.3, randf_range(-1,1))
	# Set new random timer value
	idle_lookaround_timer.wait_time = randf_range(tower_lookaround_time_range.x, tower_lookaround_time_range.y)
		

# Tracking state:
# 	Constantly look at the enemy and fire every few seconds
func _active_state() -> void:
	super()
	var enemy: Node3D = _get_target()
	if !enemy:
		if debug: print("No tower target, transitioning to idle")
		_transition_to_idle_state()
		return
	
	if debug: print("Target seen")
	
	tower_look_desired = tower_head.global_position.direction_to(enemy.global_position)

func _on_firing_timer_timeout() -> void:
	if state != TowerState.Active: return
	_fire_bolt(_get_target())
	firing_timer.start()

# Non-state-specific functions
func _fire_bolt(bolt_target: Node3D) -> void:
	var new_bolt: Node3D = tower_Attack_Visual.instantiate()
	new_bolt.transform = tower_head.transform
	new_bolt.target = bolt_target
	new_bolt.damage = damage
	add_child(new_bolt)
	# Play crossbow sound
	AudioManager.play_sfx("crossbow")
	

func _get_target() -> Node3D:
	# Easily could implement bloons-type targeting (closest to tower, closest to base, etc)
	var enemies: Array[Node3D] = attack_area.get_overlapping_bodies().filter(func(b:Node3D)->bool: return b.is_in_group("enemy"))
	# Is there actually anything nearby?
	if enemies.is_empty():
		return null
	elif enemies.size() == 1: # if there is only one enemy then just return that one immediately.
		return enemies.front()
	
	# since there is multiple targets find best fit for tower.
	enemies.sort_custom(func(n1:Node3D, n2:Node3D)->bool: return n1.global_position.distance_to(global_position) < n2.global_position.distance_to(global_position))
	var target: Node3D
	match targeting:
		TargetType.Close:
			target = enemies.front()
		TargetType.Far:
			target = enemies.back()
		TargetType.Objective:
			enemies.sort_custom(func(n1:Node3D, n2:Node3D)->bool: return n1.global_position.distance_to(objective.global_position) < n2.global_position.distance_to(objective.global_position))
			target = enemies.front()
		TargetType.Player:
			enemies.sort_custom(func(n1:Node3D, n2:Node3D)->bool: return n1.global_position.distance_to(player.global_position) < n2.global_position.distance_to(player.global_position))
			target = enemies.front()
	# Return filtered enemy
	return target
