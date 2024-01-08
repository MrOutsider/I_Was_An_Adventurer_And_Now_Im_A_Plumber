extends CharacterBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer

@export var speed : float = 10.0
@export var friction : float = 1.0
@export var acceleration : float = 1.0

enum PLAYER_STATES {IDLE, MOVING, ATTACKING, DASHING, HURTING}
var player_state : int = PLAYER_STATES.IDLE

enum PLAYER_POINTING {UP, DOWN, LEFT, RIGHT}
var player_pointing : int = PLAYER_POINTING.DOWN

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
	animate_sprite()

func _physics_process(delta):
	if (input_dir.length() > 0.0):
		velocity = lerp(velocity, input_dir * speed * 20.0, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	move_and_slide()

func animate_sprite() -> void:
	match player_state:
		PLAYER_STATES.IDLE:
			match player_pointing:
				PLAYER_POINTING.UP:
					anim_player.play("idle_up")
				PLAYER_POINTING.DOWN:
					anim_player.play("idle_down")
				PLAYER_POINTING.LEFT:
					anim_player.play("idle_left")
				PLAYER_POINTING.RIGHT:
					anim_player.play("idle_right")
