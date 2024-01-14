extends Area2D

@export var heavy_only : bool = true

@onready var sprite : Sprite2D = $Sprite2D
@export var texture : Texture
@export var region_off : Rect2
@export var region_on : Rect2

var switched_on : bool = false

signal switch_used(state : bool)

func _ready():
	body_entered.connect(body_on_plate, 1)
	body_exited.connect(body_left_plate, 1)
	sprite.texture = AtlasTexture.new()
	sprite.texture.atlas = texture
	sprite.texture.region = region_off

func body_on_plate(body : Node2D) -> void:
	if (body.is_in_group("heavy")):
		switched_on = true
		sprite.texture.region = region_on
		switch_used.emit(switched_on)

func body_left_plate(_body : Node2D) -> void:
	switched_on = false
	for n in get_overlapping_bodies():
		if (n.is_in_group("heavy")):
			switched_on = true
	if (!switched_on):
		sprite.texture.region = region_off
		switch_used.emit(switched_on)
