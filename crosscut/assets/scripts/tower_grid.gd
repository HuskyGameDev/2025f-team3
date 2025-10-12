extends GridMap

# The center of the grid is wherever the grid is place
# The bounds of the grid are controlled by the raycast children

const debug = true

# Map from vector2 to tower node
var size_across = 20
var towers: Dictionary[Vector2i, Node3D] = {}

func _ready():
	pass
	
# Adds a tower on the closest spot in the grid
func add_tower(tower: PackedScene, pos: Vector3):
	var position_2D = Vector2(pos.x, pos.z)
	
	var closest_pos = get_closest_position_on_grid(position_2D)
	if towers.has(closest_pos):
		if debug: print("GRID: tower already exists at pos")
		return
		
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
		return
	
	var the_tower: Node3D = towers[closest_pos]
	the_tower.queue_free()
	towers.erase(closest_pos)
	
func get_closest_position_on_grid(place_pos: Vector2) -> Vector2i:
	var pos_x = place_pos.x
	var pos_y = place_pos.y
	var closest_pos: Vector2i = place_pos
	
	closest_pos.x = round(pos_x/cell_size.x)*cell_size.x
	closest_pos.y = round(pos_y/cell_size.y)*cell_size.y
	
	#print(closest_pos)
	return closest_pos
