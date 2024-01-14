extends Node

enum GAME_STATES {MENU, IN_GAME}
var game_state = GAME_STATES.MENU

var music_volume : int = 100
var sfx_volume : int = 100

signal game_state_change(value : GAME_STATES)
signal music_volume_change(value : int)
signal sfx_volume_change(value : int)

func change_game_state(value : GAME_STATES) -> void:
	game_state = value
	game_state_change.emit(value)

func change_music(value : int) -> void:
	if (music_volume != value):
		music_volume = value
		music_volume_change.emit(value)

func change_sfx(value : int) -> void:
	if (sfx_volume != value):
		sfx_volume = value
		sfx_volume_change.emit(value)
