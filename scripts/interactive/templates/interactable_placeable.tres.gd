extends Node2D

@export var pre_place_sprite : Sprite2D
@export var placed_sprite : Sprite2D
@export var focus_sprite : Sprite2D
@onready var area_2d : Area2D = $Interactable
@onready var static_body_2d : StaticBody2D = $PlacedBody

@export var can_use : bool = false
@export var placed : bool = false

signal switch_used(state : bool)

func _ready():
	pre_place_sprite.show()
	placed_sprite.hide()
	focus_sprite.hide()

# Interactable Code
func focus() -> void:
	if (!placed):
		focus_sprite.show()

func lose_focus() -> void:
	if (!placed):
		focus_sprite.hide()

# Placeable Code
func use() -> void:
	if (!placed):
		placed = true
		focus_sprite.hide()
		pre_place_sprite.hide()
		placed_sprite.show()
		static_body_2d.set_collision_layer_value(1, true)
		area_2d.monitorable = false
		area_2d.call_deferred("queue_free")
		switch_used.emit(true)
