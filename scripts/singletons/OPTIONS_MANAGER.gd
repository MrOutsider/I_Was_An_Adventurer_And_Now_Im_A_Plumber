extends Node

enum GAME_STATES {MENU, IN_GAME}
var game_state = GAME_STATES.MENU

var master_volume : int = 100
var music_volume : int = 100
var sfx_volume : int = 100

signal game_state_change(value : GAME_STATES)

func change_game_state(value : GAME_STATES) -> void:
	game_state = value
	game_state_change.emit(value)

func change_master_volume(value : int) -> void:
	if (master_volume != value):
		master_volume = value
		AudioServer.set_bus_volume_db(0, linear_to_db(value / 100.0))

func change_music_volume(value : int) -> void:
	if (music_volume != value):
		music_volume = value
		AudioServer.set_bus_volume_db(1, linear_to_db(value / 100.0))

func change_sfx_volume(value : int) -> void:
	if (sfx_volume != value):
		sfx_volume = value
		AudioServer.set_bus_volume_db(2, linear_to_db(value / 100.0))
