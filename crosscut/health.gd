extends Node

signal damaged_sig(damage_taken: int, health_after_damage: int)
signal killed_sig

@export var debug: bool = false
@export var max_health: int
@export var has_particles: bool
@export var hitFX: GPUParticles3D #assigned as child in editor

# Health bar system: left side scales with health and right side scales with max_health - health
@export var healthBarL: Sprite3D
@export var healthBarR: Sprite3D
@export var has_health_bar: bool = false # false default to prevent error

@onready var health: float = max_health

func restore_health() -> void:
	health = max_health
	update_health_bar()

func take_damage(damage: int) -> void:
	if debug: print("Current health is ", health)
	health -= damage
	damaged_sig.emit(damage, health)
	
	if has_particles:
		hitFX.restart() #display hit particle FX
	
	if debug: print("Health after damage: ", health, " (max: ", max_health, ")")
	if health <= 0:
		if debug: print("HEALTH ZERO - EMITTING KILLED SIGNAL for: ", get_parent().name)
		killed_sig.emit()
		
	update_health_bar()
		
func update_health_bar() -> void:
	if has_health_bar:
		var scale: float = max_health / 64.0
		healthBarL.region_rect.size.x = health / scale
		healthBarR.region_rect.size.x = ((max_health - health) / scale) * -1
