extends Node

@onready var WORLD = $World
@onready var main_menu = $MainMenu

@export var new_game_button : Button
@export var load_game_button : Button
@export var options_button : Button
@export var quit_button : Button

@onready var test_level_1 : PackedScene = preload("res://levels/technical/test_level_1.tscn")

func _ready():
	new_game_button.pressed.connect(start_new_game)
	quit_button.pressed.connect(quit_game)

func start_new_game() -> void:
	main_menu.queue_free()
	var n = test_level_1.instantiate()
	WORLD.add_child(n)

func quit_game() -> void:
	get_tree().quit()
