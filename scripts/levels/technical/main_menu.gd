extends Node

@export var new_game_button : Button
@export var load_game_button : Button
@export var options_button : Button
@export var quit_button : Button

func _ready():
	new_game_button.pressed.connect(start_new_game)
	quit_button.pressed.connect(quit_game)

func start_new_game() -> void:
	pass

func quit_game() -> void:
	get_tree().quit()
