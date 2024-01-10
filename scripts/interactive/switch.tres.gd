extends CharacterBody2D

@onready var lever_on = $LeverOn
@onready var lever_off = $LeverOff


@export var switched_on : bool = false
@export var can_toggle : bool = false

var toggled : bool = false

func _ready():
	lever_off.hide()
	if switched_on:
		lever_on.show()
	else:
		lever_off.show()

func flip_switch() -> void:
	if (!toggled):
		if (!can_toggle): toggled = true
		if (switched_on):
			switched_on = false
			lever_on.hide()
			lever_off.show()
		else:
			switched_on = true
			lever_off.hide()
			lever_on.show()
