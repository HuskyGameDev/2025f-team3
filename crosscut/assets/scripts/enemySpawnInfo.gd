class_name EnemySpawnInfo extends Node

var spawnPoints = {}

#var enemyListInstance = load("res://assets/scenes/enemy_list.tscn").instantiate()
var enemyList = {
	"test1": preload("res://assets/scenes/Enemy1.tscn"),
	#"test2": enemyListInstance.get_node("Enemy2")
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

func _ready():
	spawnPoints = {
		"test": get_parent().get_node("TESTSPAWN")
	}

func startSpawning():
	currentEnemyCount = 0
	if (enemyList[enemyName] != null):
		spawn()
	
func spawn():
	if currentEnemyCount < enemyCount:
		currentEnemyCount += 1
		print("Spawning ", enemyList[enemyName], " at ", locations[spawnLocationIndex])
		
		var enemyScene = enemyList[enemyName]
		if enemyScene:
			var enemyInstance = enemyScene.instantiate()
			get_tree().currentScene.call_deferred("add_child", enemyInstance)
			var spawnPos = spawnPoints[locations[spawnLocationIndex]].global_position
			enemyInstance.call_deferred("set_global_position", spawnPos)

			
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
