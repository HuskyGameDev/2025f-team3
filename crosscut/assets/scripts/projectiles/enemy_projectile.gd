extends Area3D

@export var speed : float = 20.0
@export var direction := Vector3.FORWARD
@export var damage : float = 10
@onready var timer : Timer = $CollisionShape3D/Timer
@onready var path: Path3D = $Path3D
@onready var pathfollow: PathFollow3D = $Path3D/PathFollow3D

var targetpos: Vector3 #set during spawning

func _ready() -> void:
	var midpoint: Vector3 = (position + targetpos) / 2
	midpoint.y += ( sqrt(midpoint.x**2 + midpoint.z**2) )
	# Ensure the projectile moves independently of its parent once spawned
	set_as_top_level(true)
	# Connect signals programmatically if not done in the editor
	#timer.timeout.connect(_on_timer_timeout)
	#path.curve.add_point(Vector3.ZERO)
	path.curve.add_point(midpoint, position, targetpos) #add starting position and ending pos to curve
	path.curve.add_point(targetpos)
	#path.curve.add_point(midpoint) 
	#path.curve.add_point(targetpos)

func _physics_process(delta:=) -> void:
	# Move the projectile in its direction
	pathfollow.progress += (speed * delta)
	global_position = pathfollow.global_position
	#direction.y -= (9.8 * delta) #apply gravity
	#global_translate(direction * speed * delta)

func _on_Timer_timeout() -> void:
	# Remove the projectile when the timer runs out
	queue_free()

func _on_Enemy_Projectile_body_entered(body: Node3D) -> void:
	# Check if the body has a method to take damage (e.g., "take_damage")
	#if body.has_method("take_damage"):
		#body.take_damage(damage)
	if body.is_in_group("player") or body.is_in_group("objective"):
		body.health.take_damage(damage, false)
	# Destroy the projectile on impact
	queue_free()

func _on_timer_timeout() -> void:
	pass # Replace with function body.
