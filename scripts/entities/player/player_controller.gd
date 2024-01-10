extends CharacterBody2D

# Node Imports
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var anim_player_attacks : AnimationPlayer = $AnimationPlayerAttacks
@onready var anim_player_effects : AnimationPlayer = $AnimationPlayerEffects
@onready var player_sprite : AnimatedSprite2D = $AnimatedSprite2D
# Modules
@export var HURTBOX : Area2D
# -> Timers
@onready var knockback_timer : Timer = $Knockback_Timer
@onready var sword_attack_timer : Timer = $Sword_Attack_Timer
# -> Colliders
@onready var sword_col : Area2D = $SwordPivot/Sword

# Constants
const FRICTION_BASE : float = 1.0
const FRICTION_KNOCKBACK : float = 0.3
const KNOCKBACK_FORCE : float = 400.0

# Stats
@export var health : int = 6
@export var weapon_dmg : int = 1
@export var speed : float = 125.0
@export var pushing_force : float = 20.0
@export var friction : float = FRICTION_BASE
@export var acceleration : float = 1.0

# State Machine
enum PLAYER_STATES {IDLE, MOVING, ATTACKING, KNOCKED_BACK, DEAD}
var player_state : int = PLAYER_STATES.IDLE
var player_last_state : int = player_state

enum PLAYER_DIRECTION_STATES {UP, DOWN, LEFT, RIGHT}
var player_direction_state : int = PLAYER_DIRECTION_STATES.DOWN
var forward_direction : Vector2 = Vector2.ZERO

# State Flags
var animation_change : bool = true

# Script Global
var input_dir : Vector2 = Vector2.ZERO

# Standard Functions
func _ready():
	player_sprite.play("idle_down") # Start Sprite Animations
	# Connecting Signal
	HURTBOX.connect("hit", take_dmg, 2)
	knockback_timer.connect("timeout", reset_after_knockback)
	sword_attack_timer.connect("timeout", reset_after_attack)
	sword_col.connect("body_entered", attack_hit, 1)
	sword_col.connect("area_entered", attack_hit, 1)

func _input(_event):
	if (Input.is_action_pressed("quit")):
		get_tree().quit()

func _process(_delta):
	process_inputs()
	animate_sprite()

func _physics_process(_delta):
	# Accelerate Or Decelerate
	if (input_dir.length() > 0.0 && player_state == PLAYER_STATES.MOVING):
		velocity = lerp(velocity, input_dir * speed, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	move_and_slide()

# Utility Functions
func process_inputs() -> void:
	if (player_state == PLAYER_STATES.IDLE || player_state == PLAYER_STATES.MOVING):
		input_dir.x = Input.get_action_raw_strength("move_right") - Input.get_action_raw_strength("move_left")
		input_dir.y = Input.get_action_raw_strength("move_down") - Input.get_action_raw_strength("move_up")
		player_dir_to_state()
		if (input_dir.length() > 1.0):
			input_dir = input_dir.normalized()
		if (input_dir.length() < 0.3):
			input_dir = Vector2.ZERO
		
		if (Input.is_action_just_pressed("attack")):
			set_player_state(PLAYER_STATES.ATTACKING)
	
	match player_state:
		PLAYER_STATES.IDLE:
			if (input_dir.length() > 0.0):
				set_player_state(PLAYER_STATES.MOVING)
		PLAYER_STATES.MOVING:
			if (input_dir.length() == 0.0):
				set_player_state(PLAYER_STATES.IDLE)

func player_dir_to_state() -> void:
	match player_state:
		PLAYER_STATES.IDLE:
			if (abs(input_dir.y) > abs(input_dir.x)):
				if (input_dir.y > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.DOWN
					forward_direction = Vector2.DOWN
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.UP
					forward_direction = Vector2.UP
					animation_change = true
			elif (abs(input_dir.y) < abs(input_dir.x)):
				if (input_dir.x > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.RIGHT
					forward_direction = Vector2.RIGHT
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.LEFT
					forward_direction = Vector2.LEFT
					animation_change = true
		PLAYER_STATES.MOVING:
			if (abs(input_dir.y) > abs(input_dir.x)):
				if (input_dir.y > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.DOWN
					forward_direction = Vector2.DOWN
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.UP
					forward_direction = Vector2.UP
					animation_change = true
			elif (abs(input_dir.y) < abs(input_dir.x)):
				if (input_dir.x > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.RIGHT
					forward_direction = Vector2.RIGHT
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.LEFT
					forward_direction = Vector2.LEFT
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
			PLAYER_STATES.KNOCKED_BACK:
				match player_direction_state:
					PLAYER_DIRECTION_STATES.UP:
						anim_player.play("idle_up")
					PLAYER_DIRECTION_STATES.DOWN:
						anim_player.play("idle_down")
					PLAYER_DIRECTION_STATES.LEFT:
						anim_player.play("idle_left")
					PLAYER_DIRECTION_STATES.RIGHT:
						anim_player.play("idle_right")
			PLAYER_STATES.ATTACKING:
				match player_direction_state:
					PLAYER_DIRECTION_STATES.UP:
						anim_player_attacks.play("attack_sword_up")
					PLAYER_DIRECTION_STATES.DOWN:
						anim_player_attacks.play("attack_sword_down")
					PLAYER_DIRECTION_STATES.LEFT:
						anim_player_attacks.play("attack_sword_left")
					PLAYER_DIRECTION_STATES.RIGHT:
						anim_player_attacks.play("attack_sword_right")
		animation_change = false

func set_player_state(new_state : PLAYER_STATES) -> void:
	player_last_state = player_state
	player_state = new_state
	animation_change = true

# Functions used by other nodes
func take_dmg(dmg : int, dir_of_atk : Vector2) -> void:
	health -= dmg
	if (health < 1):
		set_player_state(PLAYER_STATES.DEAD)
	knockback(dir_of_atk)

func knockback(knockback_vector : Vector2) -> void:
	if (player_state != PLAYER_STATES.KNOCKED_BACK && knockback_vector.length() > 0.0):
		set_player_state(PLAYER_STATES.KNOCKED_BACK)
		friction = FRICTION_KNOCKBACK
		velocity = velocity + (knockback_vector * KNOCKBACK_FORCE)
		knockback_timer.start()

# Function for when weapon hits collider
func attack_hit(body) -> void:
	if (body.is_in_group("player")):
		return
	if (body.is_in_group("switch")):
		body.flip_switch()
	if (body.is_in_group("movable")):
		body.linear_velocity = forward_direction * pushing_force
	if (body.is_in_group("enemy")):
		body.take_dmg(1, forward_direction)
	if (body.is_in_group("solid")):
		knockback(forward_direction * -1.0)

# Functions triggered by timers
func reset_after_attack() -> void:
	if (player_state == PLAYER_STATES.ATTACKING):
		set_player_state(PLAYER_STATES.IDLE)

func reset_after_knockback() -> void:
	if (player_state == PLAYER_STATES.KNOCKED_BACK):
		friction = FRICTION_BASE
		set_player_state(PLAYER_STATES.IDLE)

