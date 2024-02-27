extends Node

# Dev
@onready var level_1 : PackedScene = preload("res://levels/level_1.tscn")

# Menu
@onready var menu_level : PackedScene = preload("res://levels/technical/main_menu_bg.tscn")

# In Game
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

# Options Variables to Globals
@export var master_audio_volume_slider : HSlider
@export var music_volume_slider : HSlider
@export var sfx_volume_slider : HSlider

# UI
@export var UI : Control

enum MENUS {MAIN, OPTIONS, IN_GAME}
var current_menu : int = -1
var last_menu : int = -1

var can_pause : bool = false

# Dev
var level : Node = null

func _ready():
	LEVEL_MANAGER.current_main = self
	# Signals
	OPTIONS_MANAGER.game_state_change.connect(pause, 1)
	# Main Menu
	new_game_button.pressed.connect(start_new_game)
	options_button.pressed.connect(goto_options_menu)
	quit_button.pressed.connect(quit_game)
	new_game_button.mouse_entered.connect(ui_mouse_over_new)
	options_button.mouse_entered.connect(ui_mouse_over_options)
	quit_button.mouse_entered.connect(ui_mouse_over_quit)
	# Options Menu
	options_back_button.pressed.connect(options_go_back)
	options_accept_button.pressed.connect(options_accept)
	options_back_button.mouse_entered.connect(ui_mouse_over_options_back)
	options_accept_button.mouse_entered.connect(ui_mouse_over_options_accept)
	# Run
	level = menu_level.instantiate()
	WORLD.add_child(level)
	MUSIC_MANAGER.load_song(2)
	MUSIC_MANAGER.play_song()
	OPTIONS_MANAGER.change_master_volume(100)
	OPTIONS_MANAGER.change_music_volume(50)
	OPTIONS_MANAGER.change_sfx_volume(100)
	call_deferred("load_options_settigns")
	main_menu.call_deferred("show")
	swap_menu(MENUS.MAIN)

func _input(_event):
	if (Input.is_action_just_pressed("menu")):
		match OPTIONS_MANAGER.game_state:
			OPTIONS_MANAGER.GAME_STATES.MENU:
				match last_menu:
					MENUS.MAIN:
						swap_menu(MENUS.MAIN)
					MENUS.IN_GAME:
						swap_menu(MENUS.IN_GAME)
			OPTIONS_MANAGER.GAME_STATES.IN_GAME:
				swap_menu(MENUS.OPTIONS)

func swap_menu(menu_id : MENUS) -> void:
	last_menu = current_menu
	main_menu.hide()
	options_menu.hide()
	
	match OPTIONS_MANAGER.game_state:
		OPTIONS_MANAGER.GAME_STATES.MENU:
			match last_menu:
				MENUS.OPTIONS:
					load_options_settigns()
			match menu_id:
				MENUS.MAIN:
					OPTIONS_MANAGER.change_game_state(OPTIONS_MANAGER.GAME_STATES.MENU)
					main_menu.show()
					current_menu = MENUS.MAIN
					new_game_button.grab_focus()
				MENUS.OPTIONS:
					OPTIONS_MANAGER.change_game_state(OPTIONS_MANAGER.GAME_STATES.MENU)
					current_menu = MENUS.OPTIONS
					options_menu.show()
					master_audio_volume_slider.grab_focus()
				MENUS.IN_GAME:
					OPTIONS_MANAGER.change_game_state(OPTIONS_MANAGER.GAME_STATES.IN_GAME)
					current_menu = MENUS.IN_GAME
		OPTIONS_MANAGER.GAME_STATES.IN_GAME:
			match menu_id:
				MENUS.OPTIONS:
					OPTIONS_MANAGER.change_game_state(OPTIONS_MANAGER.GAME_STATES.MENU)
					current_menu = MENUS.OPTIONS
					options_menu.show()
					master_audio_volume_slider.grab_focus()

func pause(value : int) -> void:
	if (can_pause):
		match value:
			OPTIONS_MANAGER.GAME_STATES.IN_GAME:
				get_tree().paused = false
			OPTIONS_MANAGER.GAME_STATES.MENU:
				get_tree().paused = true

# Main Menu
func start_new_game() -> void:
	# TMP
	UI.show()
	# TMP
	can_pause = true
	swap_menu(MENUS.IN_GAME)
	level.queue_free()
	level = level_1.instantiate()
	WORLD.add_child(level)
	PLAYER.set_pipe(0)
	PLAYER.set_hp(5)
	MUSIC_MANAGER.load_song(4)
	MUSIC_MANAGER.play_song()

func goto_options_menu() -> void:
	music_volume_slider.value = OPTIONS_MANAGER.music_volume
	sfx_volume_slider.value = OPTIONS_MANAGER.sfx_volume
	swap_menu(MENUS.OPTIONS)

func quit_game() -> void:
	get_tree().quit()

# Options Menu
func load_options_settigns() -> void:
	master_audio_volume_slider.value = OPTIONS_MANAGER.master_volume
	music_volume_slider.value = OPTIONS_MANAGER.music_volume
	sfx_volume_slider.value = OPTIONS_MANAGER.sfx_volume

func save_options() -> void:
	OPTIONS_MANAGER.change_master_volume(int (master_audio_volume_slider.value))
	OPTIONS_MANAGER.change_music_volume(int (music_volume_slider.value))
	OPTIONS_MANAGER.change_sfx_volume(int (sfx_volume_slider.value))

func options_go_back() -> void:
	load_options_settigns()
	match last_menu:
		MENUS.MAIN:
			swap_menu(MENUS.MAIN)
		MENUS.IN_GAME:
			swap_menu(MENUS.IN_GAME)

func options_accept() -> void:
	save_options()
	match last_menu:
		MENUS.MAIN:
			swap_menu(MENUS.MAIN)
		MENUS.IN_GAME:
			swap_menu(MENUS.IN_GAME)

# Main Menu UI Focus
func ui_mouse_over_new() -> void:
	new_game_button.grab_focus()

func ui_mouse_over_options() -> void:
	options_button.grab_focus()

func ui_mouse_over_quit() -> void:
	quit_button.grab_focus()

# Options UI Focus
func ui_mouse_over_options_back() -> void:
	options_back_button.grab_focus()

func ui_mouse_over_options_accept() -> void:
	options_accept_button.grab_focus()
