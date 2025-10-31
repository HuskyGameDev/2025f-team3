extends Resource
class_name GameWeaponData

enum WeaponType { MELEE, BOW }

@export_category("identity")
@export var name: String = ""
@export var type: WeaponType = WeaponType.MELEE

@export_category("timing")
@export_range(0.05, 2.0, 0.01) var cooldown: float = 0.25
@export var automatic: bool = false  

@export_category("damage")
@export var damage: float = 10.0
@export var headshot_multiplier: float = 1.5

@export_category("range")
@export_range(0.5, 200.0, 0.5) var range_m: float = 3.0 

@export_category("fx/sfx")
@export var attack_sounds: Array[AudioStream] = []
