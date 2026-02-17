extends GridMap

# The center of the grid is wherever the grid is place
# The bounds of the grid are controlled by the raycast children

const debug = true

# Map from vector2 to tower node
var size_across: float = 50 # NOTE: Odd amounts do not work.
var hidden_hl: bool = true;
var towers: Dictionary[Vector2i, Node3D] = {}
var highlights:  Dictionary[Vector2i, Node3D] = {} #TODO: remove the Node3d portion????

@onready var navigationThing: NavigationRegion3D = $".."
func _ready() -> void:
	pass
	
func get_grid_center() -> Vector3:
	return position;
	
func highlight_tile(highlight_y: PackedScene, highlight_r: PackedScene, pos: Vector3) -> Vector3:
	var position_2D: Vector2 = Vector2(pos.x, pos.z)
	
	var closest_pos: = get_closest_position_on_grid(position_2D)
	
	# Check if desired position is out of bounds
	if not closest_pos:
		return Vector3.INF
	
	# Check if the grid position is already highlighted
	if highlights.has(closest_pos):
		return Vector3.INF
	
	# TODO: check if tower alredy there, highlight red
	if towers.has(closest_pos):
		for hl in highlights:
			var last_hl: Node3D = highlights[hl]
			last_hl.queue_free()
			highlights.erase(hl)
		
		var new_highlight: = highlight_r.instantiate()
		add_child(new_highlight)
	
		new_highlight.global_position = Vector3(closest_pos.x, position.y, closest_pos.y)
		highlights[closest_pos] = new_highlight
		return position

	for hl in highlights:
		var last_hl: Node3D = highlights[hl]
		last_hl.queue_free()
		highlights.erase(hl)
		
	var new_highlight: = highlight_y.instantiate()
	add_child(new_highlight)
	
	new_highlight.global_position = Vector3(closest_pos.x, position.y, closest_pos.y)
	highlights[closest_pos] = new_highlight
	return position

func toggle_highlight() -> void:
	if (hidden_hl == true):
		hidden_hl = false
		for hl in highlights:
			var current_hl: Node3D = highlights[hl]
			current_hl.show();
	else:
		hidden_hl = true
		for hl in highlights:
			var current_hl: Node3D = highlights[hl]
			current_hl.hide();

# Adds a tower on the closest spot in the grid
func add_tower(tower: PackedScene, pos: Vector3) -> Vector3:
	var position_2D: = Vector2(pos.x, pos.z)
	
	var closest_pos: = get_closest_position_on_grid(position_2D)
	
	# Check if desired position is out of bounds
	if not closest_pos:
		return Vector3.INF
	
	# Check if the grid position is already filled
	if towers.has(closest_pos):
		if debug: print("GRID: tower already exists at pos")
		return Vector3.INF
	
	# Otherwise, add the tower
	var new_tower: = tower.instantiate()
	add_child(new_tower, true)
	
	new_tower.global_position = Vector3(closest_pos.x, position.y, closest_pos.y)
	towers[closest_pos] = new_tower
	
	navigationThing.bake_navigation_mesh()
	print("I AM BAKING")
	
	return position

func remove_tower_at_position(pos: Vector3) -> int:
	var position_2D: = Vector2(pos.x, pos.z)
	
	var closest_pos: = get_closest_position_on_grid(position_2D)
	if !towers.has(closest_pos):
		if debug: print("GRID: no tower to delete at pos")
		return -1
	size_across
	var the_tower: Node3D = towers[closest_pos]
	the_tower.queue_free()
	towers.erase(closest_pos)
	return 0
	
func get_tower_at_position(pos: Vector3) -> Tower:
	var position_2D: = Vector2(pos.x, pos.z)
	
	var closest_pos: = get_closest_position_on_grid(position_2D)
	if !towers.has(closest_pos):
		if debug: print("GRID: no tower at pos")
		return null
	var the_tower: Node3D = towers[closest_pos]
	return the_tower
	
func get_closest_position_on_grid(place_pos: Vector2) -> Vector2i:
	var pos_x: = place_pos.x
	var pos_y: = place_pos.y
	var closest_pos: Vector2 = place_pos
	
	# Calculate grid position
	closest_pos.x = round(pos_x/cell_size.x)*cell_size.x
	closest_pos.y = round(pos_y/cell_size.y)*cell_size.y
	
	# Clamp to dimensions
	var out_of_bounds_x: bool = closest_pos.x > size_across/2 || closest_pos.x < -size_across/2 
	var out_of_bounds_y: bool = closest_pos.y > size_across/2 || closest_pos.y < -size_across/2
	
	if out_of_bounds_x || out_of_bounds_y:
		return Vector2.INF
	
	return closest_pos
