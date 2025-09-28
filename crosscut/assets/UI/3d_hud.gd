extends CanvasLayer

var time_elapsed = 0
var health = 100
var health_width

func _ready():
	# health_width assignment doesn't occur unless we await
	await get_tree().process_frame
	health_width = $HealthPanel/VBoxContainer/HealthRect.size.x

func _process(delta: float) -> void:
	time_elapsed += delta
	
	# Calculate and display time to HUD
	var seconds = snapped(fmod(time_elapsed, 60), 0.01)
	var minutes = floor(time_elapsed / 60)
	var time = str(str("%02d" % snapped(fmod(minutes, 2), 1)), ":", str("%05.2f" % seconds))
	$TimePanel/HBoxContainer/Time2.text = time
	
	# Decrease health bar just to show it works
	print($HealthPanel/VBoxContainer/HealthRect.size.x)
	health -= 0.1
	if (health < 1):
		health = 100
	$HealthPanel/VBoxContainer/HealthRect.size.x = health_width - ((100 + (health * -1)) / 100) * health_width
	
