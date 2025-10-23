class_name EnemySpawnInfo extends Node

var enemyListInstance = load("res://assets/scenes/enemy_list.tscn").instantiate()
var enemyList = {
	"test1": enemyListInstance.get_node("Enemy1"),
	"test2": enemyListInstance.get_node("Enemy2")
}

var enemyCount = 0
var enemyName = ""
var locations = []
var delay = 0.0

var currentEnemyCount = 0
var spawnLocationIndex = 0
var spawnTimer

func _init(countArg: int, nameArg: String, 
					spawnArg: Array[String], delayArg: float):
	enemyCount = countArg
	enemyName = nameArg
	locations = spawnArg
	delay = delayArg
	spawnTimer = makeTimer()


func startSpawning():
	currentEnemyCount = 0
	if (enemyList[enemyName] != null):
		spawn()
	
func spawn():
	if currentEnemyCount <= enemyCount:
		currentEnemyCount += 1
		print("Spawning ", enemyList[enemyName], " at ", locations[spawnLocationIndex])
		spawnLocationIndex = (spawnLocationIndex + 1) % locations.size()
		spawnTimer.start()
	else:
		queue_free()
		
func makeTimer():
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = delay
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	return timer

func _on_timer_timeout() -> void:
	spawn()
