extends Node2D
@onready var playerUI = %"3dHud"

@onready var levelDelay = $LevelDelay
@onready var waveDelay = $WaveDelay

var currentLevelIndex = 0
var currentWaveIndex = 0
var totalEnemies = 0
var aliveEnemies = 0
var doneSpawning = false
var levelDone = false

var levelGenerator: LevelGenerator

func _ready() -> void:
	levelGenerator = LevelGenerator.new()
	add_child(levelGenerator)
	
	startSpawning()

func startSpawning():
	var currentLevel = getCurrentLevel()
	
	if currentWaveIndex < currentLevel.size():
		var currentWave = currentLevel[currentWaveIndex]
		startWave(currentWave)
	else:
		levelDone = true
		print("Level ", currentLevelIndex, " completed!")

func getCurrentLevel() -> Array:
	var presetLevel = LevelData.getDefaultLevel(currentLevelIndex)
	if not presetLevel.is_empty():
		print("Using premade level ", currentLevelIndex)
		return presetLevel
	
	print("Generating level ", currentLevelIndex)
	return levelGenerator.generateLevel(currentLevelIndex)

func startWave(waveInfo: Array):
	totalEnemies = 0
	aliveEnemies = 0
	
	for enemy in waveInfo:
		add_child(enemy)
		enemy.startSpawning()
		totalEnemies += enemy.enemyCount
		aliveEnemies += enemy.enemyCount
	
	playerUI._update_enemies_left(totalEnemies)
	playerUI._update_enemies_killed(aliveEnemies)
	
	print("Wave started: ", totalEnemies, " total enemies, ", aliveEnemies, " alive enemies")
	doneSpawning = true

func killedEnemy():
	aliveEnemies -= 1
	playerUI._update_enemies_killed(aliveEnemies)
	print("Killed enemy ", aliveEnemies, " remain")
	
	if aliveEnemies == 0 && doneSpawning:
		print("All enemies killed, going to next wave")
		nextWave()

func nextWave():
	currentWaveIndex += 1
	doneSpawning = false
	waveDelay.start()

func nextLevel():
	currentLevelIndex += 1
	currentWaveIndex = 0
	levelDelay.start()

func _input(event):
	if event.is_action_pressed("NextLevel") && levelDone:
		print("Starting Next Level")
		levelDone = false
		nextLevel()

func _on_wave_delay_timeout():
	print("Wave delay finished")
	startSpawning()

func _on_level_delay_timeout():
	print("Level delay finished")
	startSpawning()
