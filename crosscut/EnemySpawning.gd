extends Node2D

var enemyList = load("res://assets/scenes/enemy_list.tscn").instantiate().get_children()

@onready var spawnDelay = $SpawnDelay
@onready var waveDelay = $WaveDelay

var waves = []
var currentWaveIndex = 0
var currentEnemyIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Testing the spawning for now
	var test = calcWaveCount(10, [20, 30, 50])
	waves = pickRandomEnemies(test)
	startSpawning()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func calcWaveCount(enemyCount: int, ratios: Array[int]) -> Array:
	var waves = []
	var totalEnemies = 0
	waves.resize(ratios.size())
	
	for i in waves.size():
		waves[i] = enemyCount * ratios[i] / 100
		if waves[i] < 1:
			waves[i] = 1
		else:
			waves[i] = floor(waves[i])
		totalEnemies += waves[i]
	
	if totalEnemies < enemyCount:
		waves[waves.size() - 1] += enemyCount - totalEnemies
	
	print(waves)
	return waves

func pickRandomEnemies(waveCount: Array) -> Array:
	# List of valid enemies that can spawn
	var waveSpawn = []
	waveSpawn.resize(waveCount.size())
	
	for i in waveSpawn.size():
		var currentWave = []
		for j in range(waveCount[i]):
			var randomEnemy = randi() % enemyList.size()
			currentWave.append(enemyList[randomEnemy])
		waveSpawn[i] = currentWave
	print(waveSpawn)
	return waveSpawn
	
func startSpawning():
	currentWaveIndex = 0
	currentEnemyIndex = 0
	spawnEnemy()

func spawnEnemy():
	if currentWaveIndex < waves.size():
		var currentWave = waves[currentWaveIndex]
		
		if currentEnemyIndex < currentWave.size():
			var enemy = currentWave[currentEnemyIndex]
			print("Spawning ", enemy.name)
			# Insert enemy spawning code here
			
			currentEnemyIndex += 1
			
			if currentEnemyIndex < currentWave.size():
				spawnDelay.start()
			else:
				currentWaveIndex +=1
				currentEnemyIndex = 0
				print("Wave Done")
				waveDelay.start()

func _on_spawn_delay_timeout() -> void:
	spawnEnemy()
	
func _on_wave_delay_timeout() -> void:
	spawnEnemy() # Replace with function body.
