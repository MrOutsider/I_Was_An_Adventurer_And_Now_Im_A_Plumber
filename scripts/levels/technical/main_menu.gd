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

# Options Variables to Globals
@export var music_volume_slider : HSlider
@export var sfx_volume_slider : HSlider

@onready var test_level_1 : PackedScene = preload("res://levels/technical/test_level_1.tscn")

enum MENUS {MAIN, OPTIONS, IN_GAME}
var current_menu : int = -1
var last_menu : int = -1

func _ready():
	var level = menu_level.instantiate()
	# Main Menu
	swap_menu(MENUS.MAIN)
	WORLD.add_child(level)
	new_game_button.pressed.connect(start_new_game)
	options_button.pressed.connect(goto_options_menu)
	quit_button.pressed.connect(quit_game)
	new_game_button.mouse_entered.connect(ui_mouse_over_new)
	options_button.mouse_entered.connect(ui_mouse_over_options)
	new_game_button.grab_focus()
	MUSIC_MANAGER.load_song(1)
	MUSIC_MANAGER.play_song()
	# Options Menu
	options_back_button.pressed.connect(options_go_back)
	options_accept_button.pressed.connect(options_accept)
	options_back_button.mouse_entered.connect(ui_mouse_over_options_back)
	options_accept_button.mouse_entered.connect(ui_mouse_over_options_accept)

func swap_menu(menu_id : MENUS) -> void:
	last_menu = current_menu
	
	main_menu.hide()
	options_menu.hide()

	match menu_id:
		MENUS.MAIN:
			OPTIONS_MANAGER.change_game_state(OPTIONS_MANAGER.GAME_STATES.MENU)
			main_menu.show()
			current_menu = MENUS.MAIN
			new_game_button.grab_focus()
		MENUS.OPTIONS:
			OPTIONS_MANAGER.change_game_state(OPTIONS_MANAGER.GAME_STATES.MENU)
			options_menu.show()
			current_menu = MENUS.OPTIONS
			music_volume_slider.grab_focus()
		MENUS.IN_GAME:
			OPTIONS_MANAGER.change_game_state(OPTIONS_MANAGER.GAME_STATES.IN_GAME)

# Main Menu
func start_new_game() -> void:
	swap_menu(MENUS.IN_GAME)
	WORLD.get_child(0).queue_free()
	main_menu.queue_free()
	var n = test_level_1.instantiate()
	WORLD.add_child(n)

func goto_options_menu() -> void:
	music_volume_slider.value = OPTIONS_MANAGER.music_volume
	sfx_volume_slider.value = OPTIONS_MANAGER.sfx_volume
	swap_menu(MENUS.OPTIONS)

func quit_game() -> void:
	get_tree().quit()

# Options Menu
func options_go_back() -> void:
	music_volume_slider.value = OPTIONS_MANAGER.music_volume
	sfx_volume_slider.value = OPTIONS_MANAGER.sfx_volume
	match last_menu:
		MENUS.MAIN:
			swap_menu(MENUS.MAIN)
		MENUS.IN_GAME:
			pass

func options_accept() -> void:
	OPTIONS_MANAGER.change_music(int (music_volume_slider.value))
	OPTIONS_MANAGER.change_sfx(int (sfx_volume_slider.value))
	
	match last_menu:
		MENUS.MAIN:
			swap_menu(MENUS.MAIN)
		MENUS.IN_GAME:
			pass

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
