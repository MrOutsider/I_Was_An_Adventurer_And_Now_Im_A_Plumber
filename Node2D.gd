extends CharacterBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer

@export var speed : float = 10.0
@export var friction : float = 1.0
@export var acceleration : float = 1.0

enum PLAYER_STATES {IDLE, MOVING, ATTACKING, DASHING, HURTING}
var player_state : int = PLAYER_STATES.IDLE

enum PLAYER_DIRECTION_STATES {UP, DOWN, LEFT, RIGHT}
var player_direction_state : int = PLAYER_DIRECTION_STATES.DOWN

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
	
	match player_state:
		PLAYER_STATES.IDLE:
			if (input_dir.length() > 0.0):
				player_state = PLAYER_STATES.MOVING
		PLAYER_STATES.MOVING:
			if (input_dir.length() == 0.0):
				player_state = PLAYER_STATES.IDLE

func _process(delta):
	player_dir_to_state()
	animate_sprite()

func _physics_process(delta):
	if (input_dir.length() > 0.0):
		velocity = lerp(velocity, input_dir * speed * 20.0, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	move_and_slide()

func player_dir_to_state() -> void:
	match player_state:
		PLAYER_STATES.IDLE:
			if (abs(input_dir.y) > abs(input_dir.x)):
				if (input_dir.y > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.DOWN
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.UP
			elif (abs(input_dir.y) < abs(input_dir.x)):
				if (input_dir.x > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.RIGHT
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.LEFT
		PLAYER_STATES.MOVING:
			if (abs(input_dir.y) > abs(input_dir.x)):
				if (input_dir.y > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.DOWN
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.UP
			elif (abs(input_dir.y) < abs(input_dir.x)):
				if (input_dir.x > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.RIGHT
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.LEFT

func animate_sprite() -> void:
	match player_state:
		PLAYER_STATES.IDLE:
			match player_direction_state:
				PLAYER_DIRECTION_STATES.UP:
					anim_player.play("idle_up")
				PLAYER_DIRECTION_STATES.DOWN:
					anim_player.play("idle_down")
				PLAYER_DIRECTION_STATES.LEFT:
					anim_player.play("idle_left")
				PLAYER_DIRECTION_STATES.RIGHT:
					anim_player.play("idle_right")
		PLAYER_STATES.MOVING:
			match player_direction_state:
				PLAYER_DIRECTION_STATES.UP:
					anim_player.play("move_up")
				PLAYER_DIRECTION_STATES.DOWN:
					anim_player.play("move_down")
				PLAYER_DIRECTION_STATES.LEFT:
					anim_player.play("move_left")
				PLAYER_DIRECTION_STATES.RIGHT:
					anim_player.play("move_right")
