extends CharacterBody2D

@export var switch : Node
@onready var door_sprite = $Sprite2D
@onready var door_collision = $CollisionShape2D
@onready var bump_sound = $BumpSound

func _ready():
	if (switch != null):
		if (switch.has_method("switched_on")):
			change_door_state(switch.switched_on)
		switch.switch_used.connect(change_door_state, 1)

func hit_sound() -> void:
	bump_sound.play()

func change_door_state(state : bool) -> void:
	if (state):
		door_sprite.hide()
		door_collision.disabled = true
	else:
		door_sprite.show()
		door_collision.disabled = false
