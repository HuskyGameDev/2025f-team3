extends Area3D

@export var speed : float = 20.0
@export var direction := Vector3.FORWARD
@export var damage : float = 10

@onready var timer : Timer = $Timer
@onready var pathfollow: PathFollow3D = get_parent()


func _physics_process(delta:=) -> void:
	if pathfollow.progress_ratio == 1:
		pathfollow.progress_ratio = 0
		queue_free()
	
	pathfollow.progress += (speed * delta)


func _on_Enemy_Projectile_body_entered(body: Node3D) -> void:
	#ignore enemies
	if body.is_in_group("Enemy"):
		return
	
	if body.is_in_group("player") or body.is_in_group("objective"):
		body.health.take_damage(damage, false)
	
	# Destroy the projectile on impact
	pathfollow.progress_ratio = 0 #must reset followpath for next projectile
	queue_free()

func _on_timer_timeout() -> void:
	pathfollow.progress_ratio = 0
	queue_free()
