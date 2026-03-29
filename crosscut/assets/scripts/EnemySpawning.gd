extends Node2D
@onready var playerUI: CanvasLayer = %"3dHud"
@onready var levelDelay: Timer = $LevelDelay
@onready var waveDelay: Timer = $WaveDelay

var currentLevel: Array
var currentLevelIndex: int = -1
var currentWaveIndex: int = 0
var totalEnemies: int = 0
var aliveEnemies: int = 0
var doneSpawning: bool = false
var levelDone: bool = false

var levelGenerator: LevelGenerator
var levelData: LevelData

func _ready() -> void:
	currentLevelIndex = -1
	currentWaveIndex = 0
	levelGenerator = LevelGenerator.new()
	levelData = LevelData.new()
	add_child(levelGenerator)
	
	#startSpawning()

func startSpawning() -> void:
	currentLevel = getCurrentLevel()
	
	if currentWaveIndex < currentLevel.size():
		var currentWave: Array = currentLevel[currentWaveIndex]
		startWave(currentWave)
	
	else:
		levelDone = true
		print("Level ", currentLevelIndex, " completed!")
		%"2dHud"._update_next_level_text(currentLevelIndex)
		$"../GameManager"._change_gold(200)
		$"../GameManager"._toggle_mode()
	

func getCurrentLevel() -> Array:
	var presetLevel: Array = levelData.getDefaultLevel(currentLevelIndex)
	if not presetLevel.is_empty():
		print("Using premade level ", currentLevelIndex)
		return presetLevel
	
	print("Generating level ", currentLevelIndex)
	return levelGenerator.generateLevel(currentLevelIndex)

func startWave(waveInfo: Array) -> void:
	
	AudioManager.play_sfx("wave_start")
	
	totalEnemies = 0
	aliveEnemies = 0
	
	for enemy: Object in waveInfo:
		if enemy == null:
			continue
		add_child(enemy)
		enemy.startSpawning()
	
	print("Wave started: ", totalEnemies, " total enemies, ", aliveEnemies, " alive enemies")
	doneSpawning = true

func killedEnemy() -> void:
	aliveEnemies -= 1
	playerUI._update_enemies_killed(aliveEnemies)
	print("Killed enemy ", aliveEnemies, " remain")
	
	if aliveEnemies == 0 && doneSpawning:
		print("All enemies killed, going to next wave")
		if currentWaveIndex + 1 < currentLevel.size():
			%"3dHud"/WaveStatus.text = str("Wave ", currentWaveIndex + 1, " complete. Beginning wave ", currentWaveIndex + 2, " soon...")
		else:
			%"3dHud"/WaveStatus.text = str("Final wave of level ", currentLevelIndex + 1 ," complete.\nReturning to tower placement soon...")
		%"3dHud"/WaveStatus.visible = true
		nextWave()

func nextWave() -> void:
	currentWaveIndex += 1
	doneSpawning = false
	waveDelay.start()

func nextLevel() -> void:
	currentLevelIndex += 1
	currentWaveIndex = 0
	levelDelay.start()
	%"3dHud"._update_wave_number(currentWaveIndex + 1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("NextLevel") && levelDone && aliveEnemies == 0:
		print("Starting Next Level")
		levelDone = false
		nextLevel()

func _on_wave_delay_timeout() -> void:
	print("Wave delay finished")
	%"3dHud"/WaveStatus.visible = false
	%"3dHud"._update_wave_number(currentWaveIndex + 1)
	startSpawning()

func _on_level_delay_timeout() -> void:
	print("Level delay finished")
	startSpawning()
	
func _get_next_level_size() -> int:
	return levelData.getDefaultLevel(currentLevelIndex + 1).size()
