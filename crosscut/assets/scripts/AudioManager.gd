extends Node

var score_dict := {}
var sfx_dict := {}

@onready var sfx_player: Array[AudioStreamPlayer] = [AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new()]
@onready var music_player := AudioStreamPlayer.new()

var sfx_volume: float = 1.0
var music_volume: float = 1.0
var master_volume:float = 1.0

func _ready() -> void: 
	for player in sfx_player: 
		add_child(player)
	add_child(music_player)

	sfx_dict["ui_click"] = preload("res://assets/audio/sfx/UI Button Click/UI Button Click.wav")
	
	sfx_dict["crossbow1"] = preload("res://assets/audio/sfx/Crossbow/Crossbow Firing - 1.wav")
	sfx_dict["crossbow2"] = preload("res://assets/audio/sfx/Crossbow/Crossbow Firing - 2.wav")
	sfx_dict["crossbow3"] = preload("res://assets/audio/sfx/Crossbow/Crossbow Firing - 3.wav")
	
	sfx_dict["enemy_hit1"] = preload("res://assets/audio/sfx/Goblin Hit/Goblin Hit1.wav")
	sfx_dict["enemy_hit2"] = preload("res://assets/audio/sfx/Goblin Hit/Goblin Hit2.wav")
	sfx_dict["enemy_hit3"] = preload("res://assets/audio/sfx/Goblin Hit/Goblin Hit3.wav")
	sfx_dict["enemy_hit4"] = preload("res://assets/audio/sfx/Goblin Hit/Goblin Hit4.wav")
	sfx_dict["enemy_hit5"] = preload("res://assets/audio/sfx/Goblin Hit/Goblin Hit5.wav")
	sfx_dict["enemy_hit6"] = preload("res://assets/audio/sfx/Goblin Hit/Goblin Hit6.wav")
	sfx_dict["enemy_hit7"] = preload("res://assets/audio/sfx/Goblin Hit/Goblin Hit7.wav")
	sfx_dict["enemy_hit8"] = preload("res://assets/audio/sfx/Goblin Hit/Goblin Hit8.wav")
	sfx_dict["enemy_hit9"] = preload("res://assets/audio/sfx/Goblin Hit/Goblin Hit 9.mp3")
	
	sfx_dict["enemy_death1"] = preload("res://assets/audio/sfx/Goblin Death/Goblin Death1.wav")
	sfx_dict["enemy_death2"] = preload("res://assets/audio/sfx/Goblin Death/Goblin Death2.wav")
	sfx_dict["enemy_death3"] = preload("res://assets/audio/sfx/Goblin Death/Goblin Death3.wav")	
	sfx_dict["enemy_death4"] = preload("res://assets/audio/sfx/Goblin Death/Goblin Death4.mp3")
	sfx_dict["enemy_death5"] = preload("res://assets/audio/sfx/Goblin Death/Goblin Death5.mp3")
	
	score_dict["menu"] = preload("res://assets/audio/music/Crosscut Main Theme Demo.mp3")
	score_dict["placement"] = preload("res://assets/audio/music/Crosscut Placement Theme.mp3")
	
func play_sfx(name: String) -> void: 
	if sfx_dict.has(name):
		for player in sfx_player:
			if not player.playing:
				player.stream = sfx_dict[name]
				player.play()

func play_music(name: String) -> void:
	if score_dict.has(name):
		music_player.stream = score_dict[name]
		music_player.play()


# Divide by 100 because the HSlider uses a max of 100
# Range for audio is 0-1.0

func update_volume(master_vol: float, music_vol: float, sfx_vol: float,) -> void:
	master_volume = (master_vol/100)
	music_volume = (music_vol/100)
	sfx_volume = (sfx_vol/100)
		
	music_player.volume_db = linear_to_db(master_volume * music_volume)
	for player in sfx_player:
		player.volume_db = linear_to_db(master_volume * sfx_volume)
