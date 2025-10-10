extends GridMap

# The center of the grid is wherever the grid is place
# The bounds of the grid are controlled by the raycast children

# Map from vector2 to tower node
var towers = {}

# Adds a tower on the closest spot in the grid
func add_tower(tower: Node3D, position: Vector2):
	var closest_pos = get_closest_position_on_grid(position)
	tower.position = Vector3(closest_pos.x, tower.position.y, closest_pos.y)
	towers[position] = tower
	return position
	
	
func get_closest_position_on_grid(place_pos: Vector2) -> Vector2i:
	var pos_x = place_pos.x
	var pos_y = place_pos.y
	var closest_pos: Vector2i = place_pos
	
	closest_pos.x = round(pos_x/cell_size.x)*cell_size.x
	closest_pos.y = round(pos_y/cell_size.y)*cell_size.y
	
	#print(closest_pos)
	return closest_pos
	
func _init() -> void:
	get_closest_position_on_grid(Vector2(3, 2))
