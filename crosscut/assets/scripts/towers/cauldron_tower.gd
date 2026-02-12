extends Tower

#TODO: rename to Melee tower

# Attack settings
# look to TowerBase for basline settings 

# This tower's splash radius is taken from the sight radius + this variable
@export var splash_radius_vision_offset: float

# Runtime variables
# look to TowerBase for basline settings 

# Local References
@onready var splash_source: Node3D = $SplashSource
@onready var attack_shape: CollisionShape3D = $AttackArea/AttackShape
func _idle_state() -> void:
	super()
	var first_seen_enemy: = _get_target()
	if first_seen_enemy:
		_transition_to_Active_state()

func _on_firing_timer_timeout() -> void:
	if state != TowerState.Active: return
	_splash()
	_transition_to_idle_state()

# Non-state-specific functions
func _splash() -> void:
	# print("splashing")
	var new_splash: = tower_Attack_Visual.instantiate()
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
