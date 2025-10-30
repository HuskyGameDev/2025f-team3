extends Node2D

var spawnInfo = load("res://assets/scripts/enemySpawnInfo.gd")

@onready var levelDelay = $LevelDelay
@onready var waveDelay = $WaveDelay

var waves = []
var currentLevelIndex = 0
var currentWaveIndex = 0

var totalEnemies = 0
var aliveEnemies = 0

var doneSpawning = false
var levelDone = false

var LEVELS = [
	# Level 1
	[
		# Wave 1
		[
			EnemySpawnInfo.new(2, "test1", ["test"], 1),
			#EnemySpawnInfo.new(2, "test2", ["south"], 0.5)
		],
		# Wave 2
		[
			#EnemySpawnInfo.new(3, "test1", ["west"], 1),
			EnemySpawnInfo.new(3, "test1", ["test"], 0.5)
		],
	],
	# Level 2
	[
		# Wave 1
		[
			EnemySpawnInfo.new(3, "test1", ["test"], 0.5)
		]
	]
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Testing the spawning for now
	
	#var test = calcWaveCount(10, [20, 30, 50])
	#waves = pickRandomEnemies(test)
	startSpawning()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func startSpawning():
	if currentLevelIndex < LEVELS.size():
		if currentWaveIndex < LEVELS[currentLevelIndex].size():
			var currentWave = LEVELS[currentLevelIndex][currentWaveIndex]
			for enemy in currentWave:
				add_child(enemy)
				enemy.startSpawning()
				totalEnemies += enemy.enemyCount
				aliveEnemies += enemy.enemyCount
			doneSpawning = true
		else:
			levelDone = true

func killedEnemy():
	totalEnemies -= 1
	print("Killed enemy ", totalEnemies, " remain")
	if (totalEnemies == 0 && doneSpawning):
		print("All enemies killed, going to next wave")
		nextWave()
func nextWave():
	currentWaveIndex += 1
	doneSpawning = false
	waveDelay.start()

func nextLevel():
	levelDelay.start()
	
func _input(event):
	if event.is_action_pressed("NextLevel") && levelDone:
		print("Starting Next Level")
		levelDone = false
		nextLevel()

func _on_wave_delay_timeout() -> void:
	print("Wave Done")
	startSpawning()

func _on_level_delay_timeout() -> void:
	currentLevelIndex +=1
	currentWaveIndex = 0
	totalEnemies = 0
	print("Level Done")
	startSpawning()


'''
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
'''
"""
	for level in LEVELS:
		for wave in level:
			for enemy in wave:
				add_child(enemy)
				enemy.startSpawning()
			print("Wave Done")
		print("Level Done")
"""	

"""
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
"""
