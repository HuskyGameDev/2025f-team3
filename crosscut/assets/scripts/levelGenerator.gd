class_name LevelGenerator extends Node

var minWaves = 2
var maxWaves = 5
var baseEnemies = 2
var levelScalingMult = 1.2

# Available enemies and spawn locations
var availableEnemies = ["test1"]
var availableLocations = ["test"]

func generateLevel(level: int) -> Array:
	var generatedLevel = []
	
	var waveCount = calculateWaveCount(level)
	
	for wave in range(waveCount):
		var generatedWave = generateWave(level, wave)
		generatedLevel.append(generatedWave)
	
	print("Generated level ", level, " with ", waveCount, " waves")
	return generatedLevel

func calculateWaveCount(level: int) -> int:
	var waves = minWaves + (level / 5)
	return clamp(waves, minWaves, maxWaves)

func generateWave(level: int, wave: int) -> Array:
	var generatedWave = []
	
	var maxVariation
	if level < 5:
		maxVariation = ceil(availableEnemies.size() * .2)
	elif level < 10:
		maxVariation = ceil(availableEnemies.size() * .5)
	else:
		maxVariation = availableEnemies.size()
	
	maxVariation = clamp(maxVariation, 1, availableEnemies.size())
	
	var numberOfTypes = randi() % int(maxVariation) + 1
	
	var randomizedEnemies = availableEnemies.duplicate()
	randomizedEnemies.shuffle()
	
	var totalEnemies = calculateEnemyCount(level, wave)
	
	var enemiesPerType = max(1, totalEnemies / numberOfTypes)
	
	for i in range(numberOfTypes):
		var enemyType = randomizedEnemies[i]
		var enemiesForThisType = enemiesPerType
		
		if i == numberOfTypes - 1:
			var enemiesAlreadyAssigned = enemiesPerType * (numberOfTypes - 1)
			enemiesForThisType = totalEnemies - enemiesAlreadyAssigned
		
		if enemiesForThisType > 0:
			var spawnLocations = pickSpawnLocations()
			var spawnDelay = calculateSpawnDelay(level)
			
			var spawnInfo = preload("res://assets/scripts/enemySpawnInfo.gd").new(
				enemiesForThisType,
				enemyType,
				spawnLocations,
				spawnDelay
			)
			generatedWave.append(spawnInfo)
	
	return generatedWave

func calculateEnemyCount(level: int, wave: int) -> int:
	var base = baseEnemies * pow(levelScalingMult, level)
	var waveMulti = wave * 0.2 
	var total = base * (1 + waveMulti)
	
	var randomVariation = 0
	if wave > 0:
		randomVariation = randi() % wave
	
	var finalAmount = int(total) + randomVariation
	
	return finalAmount

func pickSpawnLocations() -> Array[String]:
	var locationCount = randi() % 2 + 1
	var tempLocation = availableLocations.duplicate()
	var selectedLocations: Array[String] = []
	
	locationCount = min(locationCount, tempLocation.size())
	
	for i in range(locationCount):
		var index = randi() % tempLocation.size()
		selectedLocations.append(tempLocation[index])
		tempLocation.remove_at(index)
		
	return selectedLocations

func calculateSpawnDelay(level: int) -> float:
	var delay = 1.0 - (level * 0.05)
	return clamp(delay, 0.3, 1.5)
