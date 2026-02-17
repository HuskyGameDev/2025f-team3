extends Node3D

@onready var player: CharacterBody3D = %Player
@onready var top_down_camera: Camera3D = %TopDownCam
@onready var first_person_camera: Camera3D = %PlayerCam
@onready var spectator_camera_body: CharacterBody3D = get_node_or_null("%SpectatorCam")
@onready var spectator_camera: Camera3D = spectator_camera_body.get_node("Camera3D") if spectator_camera_body else null

@onready var first_person_HUD: CanvasLayer = %"3dHud"
@onready var top_down_HUD: CanvasLayer = %"2dHud"

# Spectator camera variables
const SPECTATOR_SPEED = 10.0
const SPECTATOR_SPRINT_MULTIPLIER = 2.0
const SPECTATOR_MOUSE_SENSITIVITY = 0.002
var spectator_velocity: Vector3 = Vector3.ZERO
signal player_died

# Game state enums
enum GameState { PRE_WAVE, WAVE_STARTING, DURING_WAVE }
enum ControlMode { PLAYER, TOPDOWN, SPECTATOR }

# Game state variables
var control_mode: = ControlMode.PLAYER
var game_state: = GameState.DURING_WAVE

var buying_tower: = false
var selected_tower: String
signal end_buying

var gold: int = 250
signal update_gold(value: int)

@onready var grid_map: = %GridMap
var crossbow_tower: = preload("res://assets/scenes/towers/crossbow_tower.tscn")
var cauldron_tower: = preload("res://assets/scenes/towers/cauldron_tower.tscn")
var highlight_tile_y: = preload("res://assets/scenes/highlight_tile_yellow.tscn")
var highlight_tile_r: = preload("res://assets/scenes/highlight_tile_red.tscn")

# Raycasting
@onready var tower_placement_raycast: RayCast3D = %TowerPlacementRaycast
const RAY_LENGTH = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_down_HUD.hide()
	update_gold.emit(gold)

	# Check if spectator camera exists
	if spectator_camera_body == null:
		push_warning("GameManager: SpectatorCam not found! Spectator mode will not work.")
	elif spectator_camera == null:
		push_warning("GameManager: SpectatorCam Camera3D child not found!")

	# Connect to objective for game over handling
	_connect_to_objective()

	# Connect to player health for spectator mode on death
	_connect_to_player()

	# Connect to enemy spawner for wave end detection
	_connect_to_spawner()
	
	_toggle_mode.call_deferred()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if spectator_camera_body == null:
		return

	if control_mode == ControlMode.SPECTATOR:
		# Only handle movement when in spectator mode
		_handle_spectator_movement(delta)
	else:
		# When NOT in spectator mode, park it far away to avoid collision issues
		spectator_camera_body.global_position = player.global_position + Vector3(0, 1000, 0)  # Way above, out of the way
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("View Map") and control_mode != ControlMode.SPECTATOR:
		_toggle_mode()

	# Handle spectator camera rotation
	if control_mode == ControlMode.SPECTATOR and event is InputEventMouseMotion:
		# Rotate the body around global Y axis to prevent tilting
		spectator_camera_body.rotate_y(-event.relative.x * SPECTATOR_MOUSE_SENSITIVITY)

		# Rotate the camera child around local X axis for pitch
		spectator_camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * SPECTATOR_MOUSE_SENSITIVITY)

		# Clamp pitch and remove any roll/tilt
		spectator_camera.rotation.x = clampf(spectator_camera.rotation.x, -deg_to_rad(89), deg_to_rad(89))
		spectator_camera.rotation.z = 0  # Lock roll to prevent tilting
	
	#highlight currently hovered tile
	if control_mode == ControlMode.TOPDOWN:
		var position: Vector3 = _get_mouse_position_on_board()
		grid_map.highlight_tile(highlight_tile_y, highlight_tile_r, position)
	
	if control_mode == ControlMode.TOPDOWN and event is InputEventMouseButton and event.pressed and event.button_index == 1:
		var position: Vector3 = _get_mouse_position_on_board()
		if (position.x >= -27 and position.x <= 27) and (position.z >= -27 and position.z <= 27):
			print(position)
			if buying_tower:
				var bought_position: Vector3
				var price: int = %"2dHud"._get_price(int(selected_tower))
				
				if gold >= price:
					match selected_tower:
						"0":
							bought_position = grid_map.add_tower(crossbow_tower, position)
						"1":
							bought_position = grid_map.add_tower(cauldron_tower, position)
					if bought_position.is_finite():
						print(str("You just bought tower "), selected_tower)
						gold -= %"2dHud"._get_price(int(selected_tower))
						update_gold.emit(gold)
					else:
						print("Buying error: Cannot place tower")
				else:
					print("Buying error: Not enough gold")
			
	elif control_mode == ControlMode.TOPDOWN and event is InputEventMouseButton and event.pressed and event.button_index == 2:
		var position: Vector3 = _get_mouse_position_on_board()
		var price: int = 50
		var tower: Tower = grid_map.get_tower_at_position(position)
		if (tower != null):
			# check what this tower is
			if(tower.name.to_lower().contains("crossbow")):
				price = (%"2dHud"._get_price(int(0))) / 2
			elif(tower.name.to_lower().contains("cauldron")):
				price = (%"2dHud"._get_price(int(1))) / 2
			if grid_map.remove_tower_at_position(position) != -1:
				# Gain back half the cost of a tower when you sell it
				# TODO: Determine the ID of the sold tower and subtract the corresponding price / 2
				gold += price
				update_gold.emit(gold)
		else:
			print("Selling error")
			
	if event.is_action_pressed("Cancel"):
		print("Buying cancelled")
		buying_tower = false
		end_buying.emit()
		
	if event.is_action_pressed("Test2"):
		_change_gold(100)
	
func _get_mouse_position_on_board() -> Vector3:
	var space_state: = get_world_3d().direct_space_state
	var mousepos: = get_viewport().get_mouse_position()
	
	var origin: = top_down_camera.project_ray_origin(mousepos)
	var end: = origin + top_down_camera.project_ray_normal(mousepos) * RAY_LENGTH
	var collision_mask: = 1
	var query: = PhysicsRayQueryParameters3D.create(origin, end, collision_mask, [self])
	query.collide_with_areas = true
	
	var result: = space_state.intersect_ray(query)
	
	return result["position"]
	
func _toggle_mode() -> void:
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
		grid_map.toggle_highlight()
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
		grid_map.toggle_highlight()
		top_down_HUD.hide()
	print(control_mode)

func _connect_to_objective() -> void:
	# Find and connect to the objective in the scene
	var objectives: = get_tree().get_nodes_in_group("objective")
	if objectives.size() > 0:
		var objective: = objectives[0]
		objective.objective_destroyed.connect(_on_objective_destroyed)
		print("GameManager connected to objective")
	else:
		push_warning("GameManager: No objective found in scene!")

func _on_objective_destroyed() -> void:
	print("GAME OVER - OBJECTIVE DESTROYED!")
	# Pause the game and show game over UI
	get_tree().paused = true
	%"3dHud".visible = false
	%"2dHud".visible = false
	$"../PauseMenu".queue_free()
	%GameOver.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# TODO: Stop enemy spawning

# Enables buying mode when you click Buy in the 2D HUD.
func _on_d_hud_begin_buying(selected: String) -> void:
	print("Begin buying")
	buying_tower = true
	selected_tower = selected
	
func _on_d_hud_end_buying() -> void:
	buying_tower = false
	selected_tower = "-1"

func _handle_spectator_movement(_delta: float) -> void:
	# Get input direction
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Calculate movement direction based on camera orientation
	# Move in the exact direction the camera is looking (no horizontal projection)
	var forward: = spectator_camera_body.global_transform.basis.z
	var right: = spectator_camera_body.global_transform.basis.x

	var direction: = (right * input_dir.x + forward * input_dir.y).normalized()

	# Calculate speed with sprint
	var current_speed: = SPECTATOR_SPEED
	if Input.is_physical_key_pressed(KEY_SHIFT):
		current_speed *= SPECTATOR_SPRINT_MULTIPLIER

	# Apply movement in the direction you're looking with collision detection
	if direction != Vector3.ZERO:
		spectator_velocity = direction * current_speed
	else:
		spectator_velocity = Vector3.ZERO

	# Use move_and_slide for collision detection
	spectator_camera_body.velocity = spectator_velocity
	spectator_camera_body.move_and_slide()

func _switch_to_spectator_mode() -> void:
	player_died.emit()
	print("Switching to spectator mode - Player died!")

	if spectator_camera == null or spectator_camera_body == null:
		push_warning("Cannot switch to spectator mode - SpectatorCam not found!")
		return

	control_mode = ControlMode.SPECTATOR

	# Move spectator camera to player death position (slightly above)
	spectator_camera_body.global_position = player.global_position + Vector3(0, 2, 0)
	spectator_camera_body.rotation.y = player.rotation.y
	spectator_camera.rotation.x = first_person_camera.rotation.x
	spectator_camera.rotation.z = 0

	print("Player died at position: ", player.global_position)
	print("Spectator camera moved to: ", spectator_camera_body.global_position)

	# Disable player controls and collision
	player.disabled = true

	# Hide the player so they don't block enemies
	player.visible = false

	# Disable player collision so enemies can pass through
	player.set_collision_layer_value(1, false)
	player.set_collision_mask_value(1, false)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Change camera
	spectator_camera.make_current()

	# Keep first person HUD visible to see game state
	first_person_HUD.show()
	top_down_HUD.hide()

func _switch_to_topdown_from_spectator() -> void:
	print("Wave ended - Switching to top-down mode for tower placement")
	control_mode = ControlMode.TOPDOWN

	# Change controls
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Change camera
	top_down_camera.make_current()

	# Change HUDs
	first_person_HUD.hide()
	top_down_HUD.show()

func _connect_to_player() -> void:
	if player:
		print("Player node found: ", player)
		print("Player children: ", player.get_children())

		# Try to find health component
		var health_node: = player.get_node_or_null("Health")
		if health_node == null:
			# Try lowercase
			health_node = player.get_node_or_null("health")

		if health_node:
			health_node.killed_sig.connect(_on_player_killed)
			print("GameManager connected to player health: ", health_node)
			print("Player current health: ", health_node.health)
		else:
			push_warning("GameManager: Player health component not found!")
			print("Available child nodes:")
			for child in player.get_children():
				print("  - ", child.name, " (", child.get_class(), ")")
	else:
		push_warning("GameManager: Player node not found!")

func _connect_to_spawner() -> void:
	var spawner: = get_node_or_null("%EnemySpawning")
	if spawner:
		# We'll connect to the wave delay timeout to detect wave ends
		spawner.get_node("WaveDelay").timeout.connect(_on_wave_ended)
		print("GameManager connected to enemy spawner")
	else:
		push_warning("GameManager: Enemy spawner not found!")

func _on_player_killed() -> void:
	print("===== PLAYER KILLED SIGNAL RECEIVED =====")
	print("Current control mode: ", control_mode)
	print("Spectator camera exists: ", spectator_camera != null)
	_switch_to_spectator_mode()

func _on_wave_ended() -> void:
	print("Wave ended detected")
	# Only switch to top-down if we're in spectator mode
	if control_mode == ControlMode.SPECTATOR:
		_switch_to_topdown_from_spectator()

func _change_gold(value: int) -> void:
	gold += value
	update_gold.emit(gold)
