class_name LevelGenerator extends Node

var minWaves: int = 2
var maxWaves: int = 5
var baseEnemies: int = 2
var levelScalingMult: float = 1.2

# Available enemies and spawn locations
var availableEnemies: Array[String] = ["test1"]
var availableLocations: Array[String] = ["test"]

func generateLevel(level: int) -> Array:
	var generatedLevel: Array = []
	
	var waveCount: int = calculateWaveCount(level)
	
	for wave in range(waveCount):
		var generatedWave: Array = generateWave(level, wave)
		generatedLevel.append(generatedWave)
	
	print("Generated level ", level, " with ", waveCount, " waves")
	return generatedLevel

func calculateWaveCount(level: int) -> int:
	var waves: int = minWaves + (level / 5)
	return clamp(waves, minWaves, maxWaves)

func generateWave(level: int, wave: int) -> Array:
	var generatedWave: Array = []
	
	var maxVariation: int
	if level < 5:
		maxVariation = ceil(availableEnemies.size() * .2)
	elif level < 10:
		maxVariation = ceil(availableEnemies.size() * .5)
	else:
		maxVariation = availableEnemies.size()
	
	maxVariation = clamp(maxVariation, 1, availableEnemies.size())
	
	var numberOfTypes: int = randi() % int(maxVariation) + 1
	
	var randomizedEnemies: Array = availableEnemies.duplicate()
	randomizedEnemies.shuffle()
	
	var totalEnemies: int = calculateEnemyCount(level, wave)
	
	var enemiesPerType: int = max(1, totalEnemies / numberOfTypes)
	
	for i in range(numberOfTypes):
		var enemyType: String = randomizedEnemies[i]
		var enemiesForThisType: int = enemiesPerType
		
		if i == numberOfTypes - 1:
			var enemiesAlreadyAssigned: int = enemiesPerType * (numberOfTypes - 1)
			enemiesForThisType = totalEnemies - enemiesAlreadyAssigned
		
		if enemiesForThisType > 0:
			var spawnLocations: Array[String] = pickSpawnLocations()
			var spawnDelay: float = calculateSpawnDelay(level)
			
			var spawnInfo: Object = preload("res://assets/scripts/enemySpawnInfo.gd").new(
				enemiesForThisType,
				enemyType,
				spawnLocations,
				spawnDelay
			)
			generatedWave.append(spawnInfo)
	
	return generatedWave

func calculateEnemyCount(level: int, wave: int) -> int:
	var base: float = baseEnemies * pow(levelScalingMult, level)
	var waveMulti: float = wave * 0.2 
	var total: float = base * (1 + waveMulti)
	
	var randomVariation: int = 0
	if wave > 0:
		randomVariation = randi() % wave
	
	var finalAmount: int = int(total) + randomVariation
	
	return finalAmount

func pickSpawnLocations() -> Array[String]:
	var locationCount: int = randi() % 2 + 1
	var tempLocation: Array[String] = availableLocations.duplicate()
	var selectedLocations: Array[String] = []
	
	locationCount = min(locationCount, tempLocation.size())
	
	for i in range(locationCount):
		var index: int = randi() % tempLocation.size()
		selectedLocations.append(tempLocation[index])
		tempLocation.remove_at(index)
		
	return selectedLocations

func calculateSpawnDelay(level: int) -> float:
	var delay: float = 1.0 - (level * 0.05)
	return clamp(delay, 0.3, 1.5)
