extends Node

@onready var audio_stream_player_1 : AudioStreamPlayer = $AudioStreamPlayer1
@onready var audio_stream_player_2 : AudioStreamPlayer = $AudioStreamPlayer2

var loaded_audio_stream : int = 0
var next_audio_stream : int = 1

var current_song_id : int = 0

# ID: 1
const the_final_of_the_fantasy : String = "res://assets/audio/music/xDeviruchi - The Final of The Fantasy.wav"

func _ready():
	audio_stream_player_1.finished.connect(song_end)
	audio_stream_player_2.finished.connect(song_end)

func load_song(song_id : int) -> void:
	var song_stream : AudioStream
	match song_id:
		1:
			current_song_id = 1
			song_stream = load(the_final_of_the_fantasy)
	
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
			audio_stream_player_1.play()
		2:
			audio_stream_player_2.play()

func song_end() -> void:
	pass
