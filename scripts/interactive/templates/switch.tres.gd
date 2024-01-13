extends CharacterBody2D

@onready var lever_on : Sprite2D = $LeverOn
@onready var lever_off : Sprite2D = $LeverOff

@onready var lever_sound : AudioStreamPlayer2D = $LeverSound

@export var switched_on : bool = false
@export var can_toggle : bool = false

var toggled : bool = false

signal switch_used(state : bool)

func _ready():
	lever_off.hide()
	if switched_on:
		lever_on.show()
	else:
		lever_off.show()

func flip_switch() -> void:
	if (!toggled):
		lever_sound.play()
		if (!can_toggle): toggled = true
		if (switched_on):
			switch_used.emit(false)
			switched_on = false
			lever_on.hide()
			lever_off.show()
		else:
			switch_used.emit(true)
			switched_on = true
			lever_off.hide()
			lever_on.show()
