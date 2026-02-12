extends ProjectileBase

var tarPos: Vector3

func _ready() -> void:
	tarPos = target.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move towards target
	global_position = global_position.move_toward(tarPos, speed*delta)
	
	# if the projectile has reached its final point
	if global_position.distance_to(tarPos) < 0.5:
		queue_free()

func _on_hit(hit: Node3D) -> void:
	hit.health.take_damage(damage)

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		_on_hit(body)
