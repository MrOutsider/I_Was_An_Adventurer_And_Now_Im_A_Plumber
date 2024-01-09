extends CharacterBody2D

@export var HP : Area2D
@onready var anim_player : AnimationPlayer = $AnimationPlayer

@export var speed : float = 7.0
@export var pushing_force = 150.0
@export var friction : float = 1.0
@export var acceleration : float = 1.0

enum PLAYER_STATES {IDLE, MOVING, ATTACKING, DASHING, HURTING, GRABBING}
var player_state : int = PLAYER_STATES.IDLE

enum PLAYER_DIRECTION_STATES {UP, DOWN, LEFT, RIGHT}
var player_direction_state : int = PLAYER_DIRECTION_STATES.DOWN

var animation_change : bool = true

var input_dir : Vector2 = Vector2.ZERO

func _ready():
	pass

func _input(event):
	if (Input.is_action_pressed("ui_cancel")):
		get_tree().quit()
	
	if (Input.is_action_just_pressed("attack")):
		player_state = PLAYER_STATES.ATTACKING
		animation_change = true
	
	if (Input.is_action_just_pressed("ui_left")):
		reset_after_attack()
	
	if (player_state == PLAYER_STATES.IDLE || player_state == PLAYER_STATES.MOVING):
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
				animation_change = true
		PLAYER_STATES.MOVING:
			if (input_dir.length() == 0.0):
				player_state = PLAYER_STATES.IDLE
				animation_change = true

func _process(delta):
	player_dir_to_state()
	animate_sprite()

func _physics_process(delta):
	# Accelerate Or Decelerate
	if (input_dir.length() > 0.0 && player_state == PLAYER_STATES.MOVING):
		velocity = lerp(velocity, input_dir * speed * 20.0, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
		
	# Move via velocity but also interact with collisions
	if (move_and_slide()):
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if (col.get_collider() is RigidBody2D):
				if (col.get_collider().is_in_group("movable")):
					col.get_collider().apply_force((col.get_normal() * pushing_force)* -1.0)
					velocity = col.get_collider().linear_velocity

func player_dir_to_state() -> void:
	match player_state:
		PLAYER_STATES.IDLE:
			if (abs(input_dir.y) > abs(input_dir.x)):
				if (input_dir.y > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.DOWN
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.UP
					animation_change = true
			elif (abs(input_dir.y) < abs(input_dir.x)):
				if (input_dir.x > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.RIGHT
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.LEFT
					animation_change = true
		PLAYER_STATES.MOVING:
			if (abs(input_dir.y) > abs(input_dir.x)):
				if (input_dir.y > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.DOWN
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.UP
					animation_change = true
			elif (abs(input_dir.y) < abs(input_dir.x)):
				if (input_dir.x > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.RIGHT
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.LEFT
					animation_change = true

func animate_sprite() -> void:
	if (animation_change):
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
			PLAYER_STATES.ATTACKING:
				match player_direction_state:
					PLAYER_DIRECTION_STATES.UP:
						anim_player.play("idle_up") # Attack
					PLAYER_DIRECTION_STATES.DOWN:
						anim_player.play("idle_down") # Attack
					PLAYER_DIRECTION_STATES.LEFT:
						anim_player.play("idle_left") # Attack
					PLAYER_DIRECTION_STATES.RIGHT:
						anim_player.play("idle_right") # Attack
		animation_change = false

func reset_after_attack() -> void:
	player_state = PLAYER_STATES.IDLE
	animation_change = true
