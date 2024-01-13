extends Node2D

@export var pre_place_sprite : Sprite2D
@export var placed_sprite : Sprite2D
@export var focus_sprite : Sprite2D
@onready var area_2d : CollisionObject2D = $Interactable
@onready var static_body_2d : CollisionObject2D = $PlacedBody

@export_enum("Horizontal", "Vertical", "Start Down", "Start Up", "Start Left", "Start Right") var pipe_piece : int
var placed : bool = false

@export var connecting_pipe : Node2D = null
@export var next_pipe : Node2D = null

signal switch_used(state : bool)

func _ready():
	pre_place_sprite.hide()
	placed_sprite.hide()
	focus_sprite.hide()
	if (connecting_pipe == null):
		placed = true
		placed_sprite.show()
		static_body_2d.set_collision_layer_value(1, true)
		if (next_pipe != null):
			next_pipe.call_deferred("reveal")

func reveal() -> void:
	pre_place_sprite.show()
	placed_sprite.hide()
	focus_sprite.hide()

# Interactable Code
func focus() -> void:
	if (!placed && connecting_pipe != null):
		if (connecting_pipe.placed):
			pre_place_sprite.hide()
			focus_sprite.show()

func lose_focus() -> void:
	if (!placed && connecting_pipe != null):
		if (connecting_pipe.placed):
			focus_sprite.hide()
			pre_place_sprite.show()

# Placeable Code
func use() -> void:
	if (!placed && connecting_pipe != null):
		if (connecting_pipe.placed):
			placed = true
			focus_sprite.hide()
			pre_place_sprite.hide()
			placed_sprite.show()
			static_body_2d.set_collision_layer_value(1, true)
			switch_used.emit(true)
			if (next_pipe != null):
				next_pipe.reveal()
