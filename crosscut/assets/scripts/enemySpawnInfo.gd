class_name EnemySpawnInfo extends Node

var playerUI: CanvasLayer
@onready var spawnManager:Object = get_parent()
var spawnPoints: Dictionary = {}

var enemyList: Dictionary = {
	"test1": preload("res://assets/scenes/Enemy1.tscn"),
	"test2": preload("res://assets/scenes/Enemy2.tscn"),
	"test3": preload("res://assets/scenes/Enemy3.tscn"),
	"test4": preload("res://assets/scenes/Enemy4.tscn"),
	"test5": preload("res://assets/scenes/Enemy5.tscn"),
	"test6": preload("res://assets/scenes/Enemy6.tscn")
}

# values for spawn location variation
var x_variation: float = 5.0
var z_variation: float = 5.0

var enemyCount: int = 0
var enemyName: String = ""
var locations: Array[String] = []
var delay: float = 0.0

var currentEnemyCount: int = 0
var spawnLocationIndex: int = 0
var spawnTimer: Object

func _init(countArg: int, nameArg: String, 
					spawnArg: Array[String], delayArg: float) -> void:
	enemyCount = countArg
	enemyName = nameArg
	locations = spawnArg
	delay = delayArg
	spawnTimer = makeTimer()

func _ready() -> void:
	spawnPoints = {
		"north": get_parent().get_node("NorthSpawn"),
		"south": get_parent().get_node("SouthSpawn"),
		"west": get_parent().get_node("WestSpawn"),
		"east": get_parent().get_node("EastSpawn")
	}

func startSpawning() -> void:
	currentEnemyCount = 0
	if (enemyList[enemyName] != null):
		spawn()
	
func spawn() -> void:
	playerUI = get_parent().playerUI
	print(spawnManager)
	if currentEnemyCount < enemyCount:
		currentEnemyCount += 1
		print("Spawning ", enemyList[enemyName], " at ", locations[spawnLocationIndex])
		
		var enemyScene: Object = enemyList[enemyName]
		if enemyScene:
			var enemyInstance: Object = enemyScene.instantiate()
			get_tree().current_scene.call_deferred("add_child", enemyInstance)
			var spawnPos: Vector3 = spawnPoints[locations[spawnLocationIndex]].global_position
			# Add variation via randomness to x and z
			spawnPos.x = spawnPos.x + (x_variation * randf() * ((randi() % 2) - 1))
			spawnPos.z = spawnPos.z + (z_variation * randf() * ((randi() % 2) - 1))
			enemyInstance.call_deferred("set_global_position", spawnPos)
			enemyInstance.name = enemyName
			spawnManager.aliveEnemies += 1
			spawnManager.totalEnemies += 1
			playerUI._update_enemies_left(spawnManager.totalEnemies)
			playerUI._update_enemies_killed(spawnManager.aliveEnemies)
			
		spawnLocationIndex = (spawnLocationIndex + 1) % locations.size()
		spawnTimer.start()
	else:
		queue_free()
		
func makeTimer() -> Object:
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = delay
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)

	return timer

func _on_timer_timeout() -> void:
	spawn()
