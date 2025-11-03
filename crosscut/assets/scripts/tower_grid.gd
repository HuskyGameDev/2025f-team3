extends GridMap

# The center of the grid is wherever the grid is place
# The bounds of the grid are controlled by the raycast children

const debug = true

# Map from vector2 to tower node
var size_across = 50 # NOTE: Odd amounts do not work.
var towers: Dictionary[Vector2i, Node3D] = {}

func _ready():
	pass
	
func get_grid_center():
	return position;
	
# Adds a tower on the closest spot in the grid
func add_tower(tower: PackedScene, pos: Vector3):
	var position_2D = Vector2(pos.x, pos.z)
	
	var closest_pos = get_closest_position_on_grid(position_2D)
	
	# Check if desired position is out of bounds
	if not closest_pos:
		return
	
	# Check if the grid position is already filled
	if towers.has(closest_pos):
		if debug: print("GRID: tower already exists at pos")
		return null
	
	# Otherwise, add the tower
	var new_tower = tower.instantiate()
	add_child(new_tower)
	
	new_tower.global_position = Vector3(closest_pos.x, position.y, closest_pos.y)
	towers[closest_pos] = new_tower
	return position

func remove_tower_at_position(pos: Vector3):
	var position_2D = Vector2(pos.x, pos.z)
	
	var closest_pos = get_closest_position_on_grid(position_2D)
	if !towers.has(closest_pos):
		if debug: print("GRID: no tower to delete at pos")
		return null
	
	var the_tower: Node3D = towers[closest_pos]
	the_tower.queue_free()
	towers.erase(closest_pos)
	return 0
	
func get_closest_position_on_grid(place_pos: Vector2):
	var pos_x = place_pos.x
	var pos_y = place_pos.y
	var closest_pos: Vector2i = place_pos
	
	# Calculate grid position
	closest_pos.x = round(pos_x/cell_size.x)*cell_size.x
	closest_pos.y = round(pos_y/cell_size.y)*cell_size.y
	
	# Clamp to dimensions
	var out_of_bounds_x = closest_pos.x > size_across/2 || closest_pos.x < -size_across/2 
	var out_of_bounds_y = closest_pos.y > size_across/2 || closest_pos.y < -size_across/2
	
	if out_of_bounds_x || out_of_bounds_y:
		return null
	
	return closest_pos
