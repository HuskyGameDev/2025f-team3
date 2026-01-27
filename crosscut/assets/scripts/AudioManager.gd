extends Node


var score_dict := {}
var sfx_dict := {}

@onready var sfx_player := AudioStreamPlayer.new()
@onready var music_player := AudioStreamPlayer.new()

func _ready() -> void: 
	add_child(sfx_player)
	add_child(music_player)
	
	sfx_dict["ui_click"] = preload("res://assets/audio/sfx/UI Button Click/UI Button Click.wav")
	sfx_dict["crossbow1"] = preload("res://assets/audio/sfx/Crossbow/Crossbow Firing - 1.wav")
	sfx_dict["crossbow2"] = preload("res://assets/audio/sfx/Crossbow/Crossbow Firing - 2.wav")
	sfx_dict["crossbow3"] = preload("res://assets/audio/sfx/Crossbow/Crossbow Firing - 3.wav")
		
	score_dict["menu"] = preload("res://assets/audio/music/Crosscut Main Theme Demo.mp3")
	score_dict["placement"] = preload("res://assets/audio/music/Crosscut Placement Theme.mp3")
	
func play_sfx(name: String) -> void: 
	if sfx_dict.has(name):
		sfx_player.stream = sfx_dict[name]
		sfx_player.play()

func play_music(name: String) -> void:
	if score_dict.has(name):
		music_player.stream = score_dict[name]
		music_player.play()
