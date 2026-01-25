class_name LevelData extends Resource

static func spawn(count: int, enemy: String, locations: Array[String], delay: float) -> EnemySpawnInfo:
	return preload("res://assets/scripts/enemySpawnInfo.gd").new(count, enemy, locations, delay)

static var DEFAULT_LEVELS: Array = [
	# Level 1
	[
		# Wave 1
		[
			spawn(2, "test1", ["test"], 1),
		],
		# Wave 2
		[
			spawn(3, "test1", ["test"], 0.5)
		],
	],
	# Level 2
	[
		# Wave 1
		[
			spawn(3, "test1", ["test"], 0.5)
		]
	]
]

static func getDefaultLevel(levelIndex: int) -> Array:
	if levelIndex < DEFAULT_LEVELS.size():
		return DEFAULT_LEVELS[levelIndex]
	else:
		return []
