extends CharacterBody2D

@onready var sprite_2d = $Sprite2D

@export var switched_on : bool = false
@export var can_toggle : bool = false

var toggled : bool = false

func _ready():
	sprite_2d.modulate = Color(0.1, 0.1, 1.0)

func flip_switch() -> void:
	if (!toggled):
		if (!can_toggle): toggled = true
		if (switched_on):
			switched_on = false
			sprite_2d.modulate = Color(0.1, 0.1, 1.0)
		else:
			switched_on = true
			sprite_2d.modulate = Color(0.1, 1.0, 0.1)
