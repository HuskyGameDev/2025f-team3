extends Node3D

@onready var player: CharacterBody3D = %Player
@onready var top_down_camera: Camera3D = %TopDownCam
@onready var first_person_camera: Camera3D = %PlayerCam

@onready var first_person_HUD: CanvasLayer = %"3dHud"
@onready var top_down_HUD: CanvasLayer = %"2dHud"


enum ControlMode { PLAYER, TOPDOWN }
var control_mode = ControlMode.PLAYER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_down_HUD.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event):
	if event.is_action_pressed("View Map"):
		_toggle_mode()
		
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
