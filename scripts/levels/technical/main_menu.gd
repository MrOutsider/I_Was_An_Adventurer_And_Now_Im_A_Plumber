extends Node

@onready var menu_level : PackedScene = preload("res://levels/technical/main_menu_bg.tscn")

@onready var WORLD = $World
@onready var main_menu = $UI_Menu/MainMenu
@onready var options_menu = $UI_Menu/OptionsMenu

# Main Menu
@export var new_game_button : Button
#@export var load_game_button : Button
@export var options_button : Button
@export var quit_button : Button

# Options Menu
@export var options_back_button : Button
@export var options_accept_button : Button
@export var options_first_node : Control

@onready var test_level_1 : PackedScene = preload("res://levels/technical/test_level_1.tscn")

func _ready():
	var level = menu_level.instantiate()
	# Main Menu
	WORLD.add_child(level)
	new_game_button.pressed.connect(start_new_game)
	new_game_button.mouse_entered.connect(ui_mouse_over_new)
	options_button.mouse_entered.connect(ui_mouse_over_options)
	quit_button.pressed.connect(quit_game)
	new_game_button.grab_focus()
	MUSIC_MANAGER.load_song(1)
	MUSIC_MANAGER.play_song()
	# Options Menu
	options_back_button.mouse_entered.connect(ui_mouse_over_options_back)
	options_accept_button.mouse_entered.connect(ui_mouse_over_options_accept)

func start_new_game() -> void:
	WORLD.get_child(0).queue_free()
	main_menu.queue_free()
	var n = test_level_1.instantiate()
	WORLD.add_child(n)

func quit_game() -> void:
	get_tree().quit()

# Main Menu UI Focus
func ui_mouse_over_new() -> void:
	new_game_button.grab_focus()

func ui_mouse_over_options() -> void:
	options_button.grab_focus()

# Options UI Focus
func ui_mouse_over_options_back() -> void:
	options_back_button.grab_focus()

func ui_mouse_over_options_accept() -> void:
	options_accept_button.grab_focus()
