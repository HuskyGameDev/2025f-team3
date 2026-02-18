class_name LevelData extends Resource

static func spawn(count: int, enemy: String, locations: Array[String], delay: float) -> EnemySpawnInfo:
	return preload("res://assets/scripts/enemySpawnInfo.gd").new(count, enemy, locations, delay)

static var DEFAULT_LEVELS: Array = [
	# Level 1
	[
		# Wave 1
		[
			spawn(7, "test1", ["north"], 0.7)
		],
		# Wave 2
		[
			spawn(8, "test1", ["west","east"], 0.4)
		]
	],
	# Level 2
	[
		# Wave 1
		[
			spawn(20, "test1", ["south", "north", "east", "west"], 0.4)
		],
		# Wave 2
		[
			spawn(15, "test1", ["east"], 0.6)
		]
	],
	# Level 3
	[
		# Wave 1
		[
			spawn(3, "test1", ["east"], 0.1),
			spawn(3, "test1", ["north"], 0.1),
			spawn(3, "test1", ["west"], 0.1)
		],
		# Wave 2
		[
			spawn(6, "test1", ["south"], 0.3)
		],
		# Wave 3
		[
			spawn(5, "test1", ["north"], 1)
		]
	],
	# Level 4
	[
		# Wave 1
		[
			spawn(3, "test1", ["north"], 0.1),
			spawn(1, "test3", ["north"], 1.0),
			spawn(3, "test1", ["east"], 0.1),
			spawn(1, "test3", ["east"], 1.0),
			spawn(3, "test1", ["south"], 0.1),
			spawn(1, "test3", ["south"], 1.0),
			spawn(3, "test1", ["west"], 0.1),
			spawn(1, "test3", ["west"], 1.0),
		],
		# Wave 2
		[
			spawn(16, "test1", ["west"], 0.3),
			#spawn(1, "test2", ["west"], 1.0) TODO: uncomment when enemy 2 targets player
		]
	]
]

static func getDefaultLevel(levelIndex: int) -> Array:
	if levelIndex < DEFAULT_LEVELS.size():
		return DEFAULT_LEVELS[levelIndex]
	else:
		return []
