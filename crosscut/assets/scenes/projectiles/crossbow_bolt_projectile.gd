extends Node3D
class_name CrossbowBolt

const debug = true
var speed = 0.2
var damage = 10

var target: Node3D

func _ready():
	print(target.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Look at target
	#var look_at = Basis.looking_at(target.position.normalized())
	#basis = look_at
	
	# Move towards target
	#position = position.move_toward(target.position, speed*delta)
	position = target.position
	# Handle collision
	if position.distance_to(target.position) < 1:
		_on_hit()

func _on_hit():
	return
	if debug: print("crossbow hit target")
	queue_free()
