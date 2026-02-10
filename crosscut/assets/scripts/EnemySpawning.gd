extends Node2D
@onready var playerUI: CanvasLayer = %"3dHud"

@onready var levelDelay: Timer = $LevelDelay
@onready var waveDelay: Timer = $WaveDelay

var currentLevelIndex: int = -1
var currentWaveIndex: int = 0
var totalEnemies: int = 0
var aliveEnemies: int = 0
var doneSpawning: bool = false
var levelDone: bool = false

var levelGenerator: LevelGenerator

func _ready() -> void:
	levelGenerator = LevelGenerator.new()
	add_child(levelGenerator)
	
	#startSpawning()

func startSpawning() -> void:
	var currentLevel: Array = getCurrentLevel()
	
	if currentWaveIndex < currentLevel.size():
		var currentWave: Array = currentLevel[currentWaveIndex]
		startWave(currentWave)
	
	else:
		levelDone = true
		print("Level ", currentLevelIndex, " completed!")
		%"2dHud"._update_next_level_text(currentLevelIndex)
		$"../GameManager"._toggle_mode()
	

func getCurrentLevel() -> Array:
	var presetLevel: Array = LevelData.getDefaultLevel(currentLevelIndex)
	if not presetLevel.is_empty():
		print("Using premade level ", currentLevelIndex)
		return presetLevel
	
	print("Generating level ", currentLevelIndex)
	return levelGenerator.generateLevel(currentLevelIndex)

func startWave(waveInfo: Array) -> void:
	totalEnemies = 0
	aliveEnemies = 0
	
	for enemy: Object in waveInfo:
		add_child(enemy)
		enemy.startSpawning()
		totalEnemies += enemy.enemyCount
		aliveEnemies += enemy.enemyCount
	
	playerUI._update_enemies_left(totalEnemies)
	playerUI._update_enemies_killed(aliveEnemies)
	
	print("Wave started: ", totalEnemies, " total enemies, ", aliveEnemies, " alive enemies")
	doneSpawning = true

func killedEnemy() -> void:
	aliveEnemies -= 1
	playerUI._update_enemies_killed(aliveEnemies)
	print("Killed enemy ", aliveEnemies, " remain")
	
	if aliveEnemies == 0 && doneSpawning:
		print("All enemies killed, going to next wave")
		nextWave()

func nextWave() -> void:
	currentWaveIndex += 1
	doneSpawning = false
	waveDelay.start()

func nextLevel() -> void:
	currentLevelIndex += 1
	currentWaveIndex = 0
	levelDelay.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("NextLevel") && levelDone && aliveEnemies == 0:
		print("Starting Next Level")
		levelDone = false
		nextLevel()

func _on_wave_delay_timeout() -> void:
	print("Wave delay finished")
	startSpawning()

func _on_level_delay_timeout() -> void:
	print("Level delay finished")
	startSpawning()
	
func _get_next_level_size() -> int:
	return LevelData.getDefaultLevel(currentLevelIndex + 1).size()
