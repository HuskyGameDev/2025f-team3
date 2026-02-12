extends Node3D
class_name ProjectileBase

const debug = false

var speed: float = 60 #was 30
var damage: int = 10

var target: Node3D
func _set_target(_n:Node3D)->void:
	print("Target set")
	target = _n
