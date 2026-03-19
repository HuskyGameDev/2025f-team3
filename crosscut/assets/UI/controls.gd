extends PanelContainer

var input_to_rebind: String
var rebinding: bool = false

## Defaults (stored in input map as input name + D):
# W: Forward
# A: Left
# S: Back
# D: Right
# Space: Jump
# LMB: Attack
# RMB: Attack(alt)
# LMB: Place
# RMB: Sell
# Esc: Pause

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get controls from input map and set button text
	var inputs: Array = $BoxContainer/HBoxContainer/Buttons.get_children()
	
	for input: Button in inputs:
		var events: Array = InputMap.action_get_events(input.name)
		input.text = events[0].as_text().replace(" (Physical)", "")
		input.pressed.connect(_rebind_key.bind(input.name)) # Allow rebind key function to get button name
	
	$BoxContainer/Label2.text = "Click on any input to rebind"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _rebind_key(key: String) -> void:
	AudioManager.play_sfx("ui_click")
	input_to_rebind = key
	rebinding = true
	$BoxContainer/Label2.text = "Currently rebinding " + key + ". Press a key/button..." 
	
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseMotion or (event is InputEventMouseButton and event.pressed == false)) and rebinding:
		print(str(event))
		InputMap.action_erase_events(input_to_rebind)
		InputMap.action_add_event(input_to_rebind, event)
		_refresh()
		rebinding = false
		$BoxContainer/Label2.text = "Click on any input to rebind"
		
func _refresh() -> void:
	var inputs: Array = $BoxContainer/HBoxContainer/Buttons.get_children()
	
	for input: Button in inputs:
		var events: Array = InputMap.action_get_events(input.name)
		input.text = events[0].as_text().replace(" (Physical)", "")
	
func _on_back_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	visible = false

func _on_defaults_pressed() -> void:
	AudioManager.play_sfx("ui_click")
	
	var inputs: Array = $BoxContainer/HBoxContainer/Buttons.get_children()

	for input: Button in inputs:
		InputMap.action_erase_events(input.name)
		InputMap.action_add_event(input.name, InputMap.action_get_events(input.name + "D")[0])
		
	_refresh()
