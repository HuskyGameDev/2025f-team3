extends CharacterBody3D
class_name Weapon

# List of all "weapon" types:
enum WeaponType {
	MELEE,
	BOW,
	STAFF,
}

@export var type : WeaponType
@export var mesh : ArrayMesh
@export var cooldown: float = 0.2 #In seconds
@export var sway : float = 0.15
@export var automatic : bool = false

@export_category("Sounds")
@export var attack_sounds : Array[AudioStream]

@export_category("WeaponStats")
@export var damage : int
@export var spread : float
@export var max_mag : int 
@export var weapon_amm : int
@export var weapon_range : int
