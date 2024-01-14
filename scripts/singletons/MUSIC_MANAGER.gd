extends Node

@onready var audio_stream_player_1 : AudioStreamPlayer = $AudioStreamPlayer1
@onready var audio_stream_player_2 : AudioStreamPlayer = $AudioStreamPlayer2

var loaded_audio_stream : int = 0
var next_audio_stream : int = 1

var current_song_id : int = 0
var queued_song_id : int = 0
var end_song : bool = false

# ID: 1
const the_final_of_the_fantasy : String = "res://assets/audio/music/xDeviruchi - The Final of The Fantasy.wav"
# ID: 2
const title_theme_loop : String = "res://assets/audio/music/Title Theme/xDeviruchi - Title Theme (Loop).wav"
# ID: 3
const title_theme_end : String = "res://assets/audio/music/Title Theme/xDeviruchi - Title Theme (End).wav"
# ID: 4
const exploring_the_unknown_intro : String = "res://assets/audio/music/Exploring The Unknown/xDeviruchi - Exploring The Unknown (Intro).wav"
# ID: 5
const exploring_the_unknown_loop : String = "res://assets/audio/music/Exploring The Unknown/xDeviruchi - Exploring The Unknown (Loop).wav"
# ID: 6
const exploring_the_unknown_end : String = "res://assets/audio/music/Exploring The Unknown/xDeviruchi - Exploring The Unknown (End).wav"
# Id: 7
const the_icy_cave_loop : String = "res://assets/audio/music/The Icy Cave/xDeviruchi - The Icy Cave (Loop).wav"
# ID: 8
const the_icy_cave_end : String = "res://assets/audio/music/The Icy Cave/xDeviruchi - The Icy Cave (End).wav"

func _ready():
	audio_stream_player_1.finished.connect(song_end)
	audio_stream_player_2.finished.connect(song_end)

func load_song(song_id : int) -> void:
	var song_stream : AudioStream
	match song_id:
		1:
			current_song_id = 1
			song_stream = load(the_final_of_the_fantasy)
		2:
			current_song_id = 2
			song_stream = load(title_theme_loop)
		3:
			current_song_id = 3
			song_stream = load(title_theme_end)
		4:
			current_song_id = 4
			song_stream = load(exploring_the_unknown_intro)
		5:
			current_song_id = 5
			song_stream = load(exploring_the_unknown_loop)
		6:
			current_song_id = 6
			song_stream = load(exploring_the_unknown_end)
		7:
			current_song_id = 7
			song_stream = load(the_icy_cave_loop)
		8:
			current_song_id = 8
			song_stream = load(the_icy_cave_end)
	
	match next_audio_stream:
		1:
			loaded_audio_stream = 1
			next_audio_stream = 2
			audio_stream_player_1.set_stream(song_stream)
		2:
			loaded_audio_stream = 2
			next_audio_stream = 1
			audio_stream_player_2.set_stream(song_stream)

func play_song() -> void:
	match loaded_audio_stream:
		1:
			audio_stream_player_2.stop()
			audio_stream_player_1.play()
		2:
			audio_stream_player_1.stop()
			audio_stream_player_2.play()

func song_end() -> void:
	match current_song_id:
		2:
			if (end_song):
				load_song(3)
				play_song()
				end_song = false
			else:
				play_song()
		4:
			load_song(5)
			play_song()
		5:
			play_song()
		7:
			play_song()

func play_new_song(song_id) -> void:
	queued_song_id = song_id
	match current_song_id:
		2:
			end_song = true
