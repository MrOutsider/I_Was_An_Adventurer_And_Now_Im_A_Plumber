extends CharacterBody2D

@export var speed : float = 10.0
@export var friction : float = 1.0
@export var acceleration : float = 1.0

var input_dir : Vector2 = Vector2.ZERO

func _ready():
	pass

func _input(event):
	if (Input.is_action_pressed("ui_cancel")):
		get_tree().quit()

	input_dir.x = Input.get_action_raw_strength("move_right") - Input.get_action_raw_strength("move_left")
	input_dir.y = Input.get_action_raw_strength("move_down") - Input.get_action_raw_strength("move_up")
	if (input_dir.length() > 1.0):
		input_dir = input_dir.normalized()
	if (input_dir.length() < 0.1):
		input_dir = Vector2.ZERO

func _process(delta):
	pass

func _physics_process(delta):
	if (input_dir.length() > 0.0):
		velocity = lerp(velocity, input_dir * speed * 20.0, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	move_and_slide()
