extends Node3D

@onready var player: CharacterBody3D = %Player
@onready var top_down_camera: Camera3D = %TopDownCam
@onready var first_person_camera: Camera3D = %PlayerCam

@onready var first_person_HUD: CanvasLayer = %"3dHud"
@onready var top_down_HUD: CanvasLayer = %"2dHud"


enum ControlMode { PLAYER, TOPDOWN }
var control_mode = ControlMode.PLAYER
@onready var grid_map = %GridMap
var crossbow_tower = preload("res://assets/scenes/towers/crossbow_tower.tscn")


# Raycasting
@onready var tower_placement_raycast: RayCast3D = %TowerPlacementRaycast
var RAY_LENGTH = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_down_HUD.hide()

	# Connect to objective for game over handling
	_connect_to_objective()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event):
	if event.is_action_pressed("View Map"):
		_toggle_mode()
	
	if control_mode == ControlMode.TOPDOWN and event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var position = _get_mouse_position_on_board()
		grid_map.add_tower(crossbow_tower, position)
	elif control_mode == ControlMode.TOPDOWN and event is InputEventMouseButton and event.pressed and event.button_index == 2:
		var position = _get_mouse_position_on_board()
		grid_map.remove_tower_at_position(position)
		
func _get_mouse_position_on_board():
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	
	var origin = top_down_camera.project_ray_origin(mousepos)
	var end = origin + top_down_camera.project_ray_normal(mousepos) * RAY_LENGTH
	var collision_mask = 1
	var query = PhysicsRayQueryParameters3D.create(origin, end, collision_mask, [self])
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	return result["position"]
	
func _toggle_mode():
	print(control_mode)
	if control_mode == ControlMode.PLAYER:
		control_mode = ControlMode.TOPDOWN
		
		# Change controls
		player.disabled = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		# Change camera
		top_down_camera.make_current()
		
		# Change huds
		first_person_HUD.hide()
		top_down_HUD.show()
	elif control_mode == ControlMode.TOPDOWN:
		control_mode = ControlMode.PLAYER
		
		# Change controls
		player.disabled = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		# Change camera
		first_person_camera.make_current()
		
		# Change huds
		first_person_HUD.show()
		top_down_HUD.hide()
	print(control_mode)

func _connect_to_objective() -> void:
	# Find and connect to the objective in the scene
	var objectives = get_tree().get_nodes_in_group("objective")
	if objectives.size() > 0:
		var objective = objectives[0]
		objective.objective_destroyed.connect(_on_objective_destroyed)
		print("GameManager connected to objective")
	else:
		push_warning("GameManager: No objective found in scene!")

func _on_objective_destroyed() -> void:
	print("GAME OVER - OBJECTIVE DESTROYED!")
	# Pause the game
	get_tree().paused = true
	# TODO: Show game over screen UI
	# TODO: Stop enemy spawning
	# For now, just print a message
