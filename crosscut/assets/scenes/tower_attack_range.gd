extends CharacterBody3D

@export var atk: int = 2
@export var atk_speed: int = 5

"""
var enemy_in_range: Array[Node3D] = []
var can_attack: bool = true

func _on_AttackRange_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		enemy_in_range.append(body)

func _on_AttackRange_body_exited(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		enemy_in_range.erase(body)

func _physics_process(delta: float) -> void:
	if not enemy_in_range.is_empty() and can_attack:
		var closest_enemy = get_closest_enemy()
		if closest_enemy:
			attack_enemy(closest_enemy)
			can_attack = false
			get_tree().create_timer(atk_speed).timeout.connect(func(): can_attack = true)

func get_closest_enemy() -> Node3D:
	if enemy_in_range.is_empty():
		return null

	var closest: Node3D = enemy_in_range[0]
	var min_distance_sq: float = global_position.distance_squared_to(closest.global_position)

	for enemy in enemy_in_range:
		var current_distance_sq: float = global_position.distance_squared_to(enemy.global_position)
		if current_distance_sq < min_distance_sq:
			min_distance_sq = current_distance_sq
			closest = enemy
	return closest

func attack_enemy(enemy: Node3D) -> void:
	if enemy.has_method("take_damage"): # Assuming enemies have a take_damage method
		enemy.towerdamage(atk)
	# Trigger attack animation or visual effects here
	print("Attacked enemy: ", enemy.name)
"""
