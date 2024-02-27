extends Node

@export var main: PackedScene
var current_main = null

func start_new_game() -> void:
	current_main.queue_free()
	var new_main: Node = main.instantiate()
	get_tree().root.add_child(new_main)
	
