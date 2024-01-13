@tool
extends Node2D

@onready var area_2d : CollisionObject2D = $Interactable
@onready var static_body_2d : CollisionObject2D = $PlacedBody
@onready var texture : String = "res://assets/art/interactive/pipes.png"
@export var pre_place_sprite : Sprite2D
@export var placed_sprite : Sprite2D
@export var focus_sprite : Sprite2D

@export_enum("Horizontal", "Vertical", "Open Down", "Open Up", "Open Left", "Open Right",
"Up Left", "Up Right", "Down Left", "Down Right") var pipe_piece : int
@export var connecting_pipe : Node2D = null
@export var next_pipe : Node2D = null

var placed : bool = false

signal switch_used(state : bool)

func _ready():
	placed_sprite.texture = AtlasTexture.new()
	placed_sprite.texture.atlas = load(texture)
	if (!Engine.is_editor_hint()):
		set_sprite()
		pre_place_sprite.hide()
		placed_sprite.hide()
		focus_sprite.hide()
		if (connecting_pipe == null):
			placed = true
			placed_sprite.show()
			#static_body_2d.set_collision_layer_value(1, true)
			if (next_pipe != null):
				next_pipe.call_deferred("reveal")

func _process(_delta):
	if (Engine.is_editor_hint()):
		set_sprite()

func reveal() -> void:
	pre_place_sprite.show()
	placed_sprite.hide()
	focus_sprite.hide()

func set_sprite() -> void:
	match pipe_piece:
		0:#  Horizontal
			placed_sprite.texture.region = Rect2(48, 16, 16, 16)
		1:# Vertical
			placed_sprite.texture.region = Rect2(48, 0, 16, 16)
		2:# Open Down
			placed_sprite.texture.region = Rect2(0, 16, 16, 16)
		3:# Open Up
			placed_sprite.texture.region = Rect2(0, 0, 16, 16)
		4:# Open Left
			placed_sprite.texture.region = Rect2(16, 0, 16, 16)
		5:# Open Right
			placed_sprite.texture.region = Rect2(32, 0, 16, 16)
		6:# Up Left
			placed_sprite.texture.region = Rect2(32, 32, 16, 16)
		7:# Up Right
			placed_sprite.texture.region = Rect2(16, 32, 16, 16)
		8:# Down Left
			placed_sprite.texture.region = Rect2(32, 16, 16, 16)
		9:# Down Right
			placed_sprite.texture.region = Rect2(16, 16, 16, 16)

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
			#static_body_2d.set_collision_layer_value(1, true)
			switch_used.emit(true)
			if (next_pipe != null):
				next_pipe.reveal()
