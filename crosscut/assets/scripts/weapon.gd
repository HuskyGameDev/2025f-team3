# res://scripts/weapon.gd
extends Node3D
class_name Weapon

const GameWeaponData = preload("res://assets/scripts/weapon_data.gd")

@export var data: GameWeaponData
var _ready_time := 0.0

func _process(delta: float) -> void:
	# just here if you later want to do cooldown UI, etc.
	pass

func can_fire() -> bool:
	return Time.get_unix_time_from_system() >= _ready_time

func try_fire(origin: Vector3, direction: Vector3) -> void:
	if not data or not can_fire(): return
	_ready_time = Time.get_unix_time_from_system() + data.cooldown

	match data.type:
		GameWeaponData.WeaponType.MELEE:
			_do_melee(origin, direction)
		GameWeaponData.WeaponType.BOW:
			_do_bow_hitscan(origin, direction)

	_play_random_attack_sound()

func _do_melee(origin: Vector3, dir: Vector3) -> void:
	var q := PhysicsRayQueryParameters3D.create(origin, origin + dir * data.range_m)
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit:
		_apply_damage(hit)

func _do_bow_hitscan(origin: Vector3, dir: Vector3) -> void:
	# single ray, no spread, longer range set in .tres
	var q := PhysicsRayQueryParameters3D.create(origin, origin + dir * data.range_m)
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	if hit:
		_apply_damage(hit)

func _apply_damage(hit: Dictionary) -> void: pass
	

func _play_random_attack_sound() -> void:
	if data.attack_sounds.is_empty(): return
	var s := AudioStreamPlayer3D.new()
	add_child(s)
	s.stream = data.attack_sounds[randi() % data.attack_sounds.size()]
	s.finished.connect(s.queue_free)
	s.play()
