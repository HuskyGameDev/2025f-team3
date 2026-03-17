extends Area3D

@export var speed : float = 20.0
@export var direction := Vector3.FORWARD
@export var damage : float = 10
@onready var timer : Timer = $MeshInstance3D/CollisionShape3D/Timer


func _ready() -> void:
	# Ensure the projectile moves independently of its parent once spawned
	set_as_top_level(true)
	# Connect signals programmatically if not done in the editor
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta:=) -> void:
	# Move the projectile in its direction
	global_translate(direction * speed * delta)

func _on_Timer_timeout() -> void:
	# Remove the projectile when the timer runs out
	queue_free()

func _on_Enemy_Projectile_body_entered(body: Node3D) -> void:
	# Check if the body has a method to take damage (e.g., "take_damage")
	if body.has_method("take_damage"):
		body.take_damage(damage)
	# Destroy the projectile on impact
	queue_free()

func _on_timer_timeout() -> void:
	pass # Replace with function body.
