extends CharacterBody2D

@onready var lever_sprite : Sprite2D = $LeverSprite
@onready var lever_sound : AudioStreamPlayer2D = $LeverSound

const texture : String = "res://assets/art/interactive/lever.png"

@export var switched_on : bool = false
@export var can_toggle : bool = false

var toggled : bool = false

signal switch_used(state : bool)

func _ready():
	lever_sprite.texture = AtlasTexture.new()
	lever_sprite.texture.atlas = load(texture)
	lever_sprite.texture.region = Rect2(0, 0, 16, 16)
	if switched_on:
		lever_sprite.texture.region = Rect2(16, 0, 16, 16)
	else:
		lever_sprite.texture.region = Rect2(0, 0, 16, 16)

func flip_switch() -> void:
	if (!toggled):
		lever_sound.play()
		if (!can_toggle): toggled = true
		if (switched_on):
			switch_used.emit(false)
			switched_on = false
			lever_sprite.texture.region = Rect2(0, 0, 16, 16)
		else:
			switch_used.emit(true)
			switched_on = true
			lever_sprite.texture.region = Rect2(16, 0, 16, 16)
