extends Node3D

@onready var debris: GPUParticles3D = $Debris
@onready var smoke: GPUParticles3D = $Smoke
@onready var fire: GPUParticles3D = $Fire
@onready var timer: Timer = $ExplosionTimer

func explode() -> void:
	debris.emitting = true
	smoke.emitting = true
	fire.emitting = true

func _on_explosion_timer_timeout() -> void:
	queue_free()
