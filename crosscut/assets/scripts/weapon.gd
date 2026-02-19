extends Node3D

class_name Weapon

@export var data: GameWeaponData

var _ready_time: float = 0.0

var _model: Node3D = null	
	
func can_fire() -> bool:
	
	return Time.get_unix_time_from_system() >= _ready_time

func try_fire(origin: Vector3, direction: Vector3) -> void:
	
	if data == null:
		
		return
		
	if not can_fire():
		
		return

	_ready_time = Time.get_unix_time_from_system() + data.cooldown

	match data.type:
		
		GameWeaponData.WeaponType.MELEE:
			
			_do_melee(origin, direction)
			
		GameWeaponData.WeaponType.BOW:
			
			_do_bow_hitscan(origin, direction)

	_play_random_attack_sound()

func _do_melee(origin: Vector3, dir: Vector3) -> void:
	
	var q: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin,origin + dir * data.range_m)
	#For testing:
	print("Ray:", origin, "->", origin + dir * data.range_m)

	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(q)
	
	if not hit.is_empty():
		
		_apply_damage(hit)

func _do_bow_hitscan(origin: Vector3, dir: Vector3) -> void:
	
	var q: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, origin + dir * data.range_m)
	
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(q)
	
	if not hit.is_empty():
		
		_apply_damage(hit)

func _apply_damage(hit: Dictionary) -> void:
	
	var collider: Object = hit.get("collider")
	
	if collider == null or collider is not Node:
		
		return

	var n: Node = collider

	# If the ray hits a child node, climb up until we find the enemy root
	while n != null and not n.is_in_group("enemy"):
		
		n = n.get_parent()

	if n == null:
		
		return

	var enemy: Node = n

	
	var h: Variant = enemy.get("health")
	
	if h != null and h is Node:
		
		var health_node: Node = h
		
		if health_node.has_method("take_damage"):
			
			health_node.call("take_damage", int(data.damage))
			
			return

	
	if enemy.has_node("Health"):
		
		var health2: Node = enemy.get_node("Health")
		
		if health2.has_method("take_damage"):
			
			health2.call("take_damage", int(data.damage))


func _play_random_attack_sound() -> void:
	
	if data == null:
		
		return
		
	if data.attack_sounds.is_empty():
		
		return

	var s: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	
	add_child(s)
	
	s.stream = data.attack_sounds[randi() % data.attack_sounds.size()]
	
	s.finished.connect(s.queue_free)
	
	s.play()
