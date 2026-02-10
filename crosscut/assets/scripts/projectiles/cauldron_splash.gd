extends Node3D

# Skip ticks
var tick_counter: int = 0
@export var ticks_per_damage_tick: int

@export var damage: int
@export var splash_time: float
var splash_radius: float # Taken from creator

@onready var splash_area: Area3D = $SplashArea
@onready var splash_shape: CollisionShape3D = $SplashArea/SplashShapeAndSize

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var final_splash_size: Vector3 = splash_shape.scale
	var final_splash_size: Vector3 = Vector3(splash_radius, splash_radius, splash_radius)
	splash_shape.scale = Vector3(1, 1, 1)
	# Tween attack radius
	var tween: = create_tween()
	tween.tween_property(splash_shape, "scale", final_splash_size, splash_time).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(_cleanup)
	
	
func _physics_process(_delta: float) -> void:
	if tick_counter % ticks_per_damage_tick == 0:
		_damage_enemies()
	tick_counter = tick_counter + 1
	
func _damage_enemies() -> void:
	var enemies: Array[Node3D] = splash_area.get_overlapping_bodies().filter(func(b:Node3D) -> bool: return b.is_in_group("enemy"))
	for enemy : Node3D in enemies:
		enemy.health.take_damage(damage)
	# print("SPLASH: damaging enemies")

func _cleanup() -> void:
	# print("SPLASH: done")
	queue_free()
