extends ProjectileBase

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Destroy if the target is gone
	if !target: #TODO: add enemy is dead condition
		if debug: print("CBB: enemy is dead or does not exist")
		queue_free() 
		return
		
	# Move towards target
	global_position = global_position.move_toward(target.global_position, speed*delta)
		
	# Look at target
	look_at(target.global_position)
	
	# Handle collision
	if global_position.distance_to(target.global_position) < 0.5:
		_on_hit()

func _on_hit() -> void:
	target.health.take_damage(damage)
	queue_free()
