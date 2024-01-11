extends CharacterBody2D

# Node Imports
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var anim_player_attacks : AnimationPlayer = $AnimationPlayerAttacks
@onready var anim_player_effects : AnimationPlayer = $AnimationPlayerEffects
@onready var player_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var music_player : AudioStreamPlayer = $MusicPlayer
# Modules
@export var HURTBOX : Area2D
# -> Timers
@onready var knockback_timer : Timer = $KnockbackTimer
@onready var sword_attack_timer : Timer = $SwordAttackTimer
# -> Colliders
@onready var sword_col : Area2D = $SwordPivot/Sword
@onready var attack_ray : RayCast2D = $AttackRay

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
@export var dead_friction : float = 0.5
@export var acceleration : float = 1.0

# State Machine
enum PLAYER_STATES {IDLE, MOVING, ATTACKING, KNOCKED_BACK, DEAD}
var player_state : PLAYER_STATES = PLAYER_STATES.IDLE
var player_last_state : PLAYER_STATES = player_state

var forward_direction : Vector2 = Vector2.ZERO
var forward_direction_last : Vector2 = forward_direction

# State Flags
var animation_change : bool = true

# Script Global
var input_dir : Vector2 = Vector2.ZERO

# Standard Functions
func _ready():
	player_sprite.play("idle_down") # Start Sprite Animations
	# Connecting Signals
	HURTBOX.hit.connect(take_dmg, 2)
	knockback_timer.timeout.connect(reset_after_knockback)
	sword_attack_timer.timeout.connect(reset_after_attack)
	sword_col.body_entered.connect(attack_hit, 1)
	sword_col.area_entered.connect(attack_hit, 1)
	# Music
	music_player.finished.connect(music_end)
	# TMP --------------------------------------------------------------------------------------------------- TMP
	#music_player.stream = load("res://assets/audio/music/xDeviruchi - The Final of The Fantasy.wav")
	#music_player.play()
	# TMP --------------------------------------------------------------------------------------------------- TMP

func _input(_event):
	if (Input.is_action_pressed("quit")):
		get_tree().quit()

func _process(_delta):
	process_inputs()
	animate_sprite()

func _physics_process(_delta):
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
		if (input_dir.length() > 1.0):
			input_dir = input_dir.normalized()
		if (input_dir.length() < 0.3):
			input_dir = Vector2.ZERO
		player_dir_to_state()
		
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
	if (abs(input_dir.y) > abs(input_dir.x)):
		if (input_dir.y > 0.0):
			forward_direction = Vector2.DOWN
		else:
			forward_direction = Vector2.UP
	elif (abs(input_dir.y) < abs(input_dir.x)):
		if (input_dir.x > 0.0):
			forward_direction = Vector2.RIGHT
		else:
			forward_direction = Vector2.LEFT
	if (forward_direction != forward_direction_last):
		animation_change = true
	forward_direction_last = forward_direction

func animate_sprite() -> void:
	if (animation_change):
		match player_state:
			PLAYER_STATES.IDLE:
				match forward_direction:
					Vector2.UP:
						anim_player.play("idle_up")
					Vector2.DOWN:
						anim_player.play("idle_down")
					Vector2.LEFT:
						anim_player.play("idle_left")
					Vector2.RIGHT:
						anim_player.play("idle_right")
			PLAYER_STATES.KNOCKED_BACK:
				match forward_direction:
					Vector2.UP:
						anim_player.play("idle_up")
					Vector2.DOWN:
						anim_player.play("idle_down")
					Vector2.LEFT:
						anim_player.play("idle_left")
					Vector2.RIGHT:
						anim_player.play("idle_right")
			PLAYER_STATES.MOVING:
				match forward_direction:
					Vector2.UP:
						anim_player.play("move_up")
					Vector2.DOWN:
						anim_player.play("move_down")
					Vector2.LEFT:
						anim_player.play("move_left")
					Vector2.RIGHT:
						anim_player.play("move_right")
			PLAYER_STATES.ATTACKING:
				match forward_direction:
					Vector2.UP:
						anim_player_attacks.play("attack_sword_up")
					Vector2.DOWN:
						anim_player_attacks.play("attack_sword_down")
					Vector2.LEFT:
						anim_player_attacks.play("attack_sword_left")
					Vector2.RIGHT:
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
		health = 0
		set_player_state(PLAYER_STATES.DEAD)
	knockback(dir_of_atk)

func knockback(knockback_vector : Vector2) -> void:
	if (player_state != PLAYER_STATES.KNOCKED_BACK && knockback_vector.length() > 0.0):
		set_player_state(PLAYER_STATES.KNOCKED_BACK)
		friction = FRICTION_KNOCKBACK
		velocity = velocity + (knockback_vector * KNOCKBACK_FORCE)
		knockback_timer.start()

# Function for when weapon hits collider
func attack_hit(body : Node2D) -> void:
	if (body.is_in_group("player")):
		return
	attack_ray.target_position = body.global_position - global_position
	attack_ray.force_raycast_update()
	if (!attack_ray.is_colliding()):
		if (body.is_in_group("switch")):
			body.flip_switch()
		if (body.is_in_group("movable")):
			body.linear_velocity = forward_direction * pushing_force
		if (body.is_in_group("enemy")):
			body.take_dmg(1, forward_direction)
		if (body.is_in_group("solid")):
			knockback(forward_direction * -1.0)
			if (body.has_method("hit_sound")):
				body.hit_sound()

# Functions triggered by timers
func reset_after_attack() -> void:
	if (player_state == PLAYER_STATES.ATTACKING):
		set_player_state(PLAYER_STATES.IDLE)

func reset_after_knockback() -> void:
	friction = FRICTION_BASE
	if (player_state == PLAYER_STATES.KNOCKED_BACK):
		set_player_state(PLAYER_STATES.IDLE)

func music_end() -> void:
	music_player.play()
