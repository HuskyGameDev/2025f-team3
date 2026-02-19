class_name LevelData extends Resource

static func spawn(count: int, enemy: String, locations: Array[String], delay: float) -> EnemySpawnInfo:
	return preload("res://assets/scripts/enemySpawnInfo.gd").new(count, enemy, locations, delay)

static var DEFAULT_LEVELS: Array = [
	# Level 1
	[
		# Wave 1
		[
			spawn(5, "test1", ["north"], 1)
		],
		# Wave 2
		[
			spawn(10, "test1", ["north"], 0.8)
		]
	],
	# Level 2
	[
		# Wave 1
		[
			spawn(8, "test1", ["north","south"], 0.6)
		],
		# Wave 2
		[
			spawn(14, "test1", ["north","south"], 0.5)
		]
	],
	# Level 3
	[
		# Wave 1
		[
			spawn(10, "test1", ["north"], 0.7),
			spawn(3, "test2", ["south"], 5)
		],
		# Wave 2
		[
			spawn(20, "test1", ["north","south"], 0.4),
			spawn(10, "test2", ["south"], 3)
		]
	],
	# Level 4
	[
		# Wave 1
		[
			spawn(1, "test3", ["south"], 0.7),
			spawn(10, "test1", ["north"], 0.6),
			spawn(7, "test1", ["south"], 1.2)
		],
		# Wave 2
		[
			spawn(4, "test3", ["south"], 5),
			spawn(15, "test1", ["north"], 0.6),
			spawn(10, "test1", ["south"], 1.2)
		]
	],
	# Level 5
	[
		# Wave 1
		[
			spawn(7, "test1", ["north"], 0.7)
		],
		# Wave 2
		[
			spawn(12, "test1", ["west","east"], 0.4)
		]
	],
	# Level 6
	[
		# Wave 1
		[
			spawn(1, "test2", ["west"], 1.0),
			spawn(20, "test1", ["south", "north", "east", "west"], 0.2)
		],
		# Wave 2
		[
			spawn(15, "test1", ["east"], 0.6)
		]
	],
	# Level 7
	[
		# Wave 1
		[
			spawn(5, "test1", ["east"], 0.1),
			spawn(5, "test1", ["north"], 0.1),
			spawn(5, "test1", ["west"], 0.1)
		],
		# Wave 2
		[
			spawn(8, "test1", ["south"], 0.3)
		],
		# Wave 3
		[
			spawn(1, "test3", ["north"], 1.0)
		]
	],
	# Level 8
	[
		# Wave 1
		[
			spawn(5, "test1", ["north"], 0.1),
			spawn(1, "test3", ["north"], 1.0),
			spawn(5, "test1", ["east"], 0.1),
			spawn(1, "test3", ["east"], 1.0),
			spawn(5, "test1", ["south"], 0.1),
			spawn(1, "test3", ["south"], 1.0),
			spawn(5, "test1", ["west"], 0.1),
			spawn(1, "test3", ["west"], 1.0),
		],
		# Wave 2
		[
			spawn(9, "test1", ["west"], 0.3),
			spawn(3, "test2", ["east"], 1.0)
		]
	],
	# Level 9 - boss wave
	[
		# Wave 1
		[
			spawn(12, "test1", ["south", "north", "east", "west"], 1.3),
			spawn(24, "test1", ["south", "north", "east", "west"], 0.5),
			spawn(12, "test2", ["south", "north", "east", "west"], 0.7),
			spawn(8, "test3", ["south", "north", "east", "west"], 0.5)
		]
	],
	# Level 10
	[
		# Wave 1
		[
			spawn(2, "test3", ["east"], 5.0),
			spawn(2, "test3", ["south"], 5.0),
			spawn(2, "test3", ["west"], 5.0),
			spawn(2, "test3", ["north"], 5.0)
		],
		# Wave 2
		[
			spawn(1, "test2", ["east"], 5.0)
		],
		# Wave 3
		[
			spawn(1, "test2", ["east"], 5.0)
		],
		# Wave 4
		[
			#evil wave
			spawn(31, "test1", ["east"], 0.01)
		]
	],
	# Level 11
	[
		# Wave 1
		[
			spawn(3, "test2", ["north"], 0.4),
			spawn(1, "test3", ["north"], 1.0),
			spawn(3, "test2", ["east"], 0.4),
			spawn(1, "test3", ["east"], 1.0),
			spawn(3, "test2", ["south"], 0.4),
			spawn(1, "test3", ["south"], 1.0),
			spawn(3, "test2", ["west"], 0.4),
			spawn(1, "test3", ["west"], 1.0),
		],
		# Wave 2
		[
			spawn(5, "test1", ["west"], 0.01),
			spawn(5, "test1", ["east"], 0.01),
		]
	],
]

static func getDefaultLevel(levelIndex: int) -> Array:
	if levelIndex < DEFAULT_LEVELS.size():
		return DEFAULT_LEVELS[levelIndex]
	else:
		return []
