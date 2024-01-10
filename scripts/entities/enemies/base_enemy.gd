extends CharacterBody2D

# Node Imports
@onready var anim_player_effects : AnimationPlayer = $AnimationPlayer
@onready var anim_player_effects_effects : AnimationPlayer = $AnimationPlayerEffects
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
# Modules
@export var HURTBOX : Area2D
# Timers
@onready var knockback_timer : Timer = $Knockback_Timer

# Constants
const FRICTION_BASE : float = 1.0
const FRICTION_KNOCKBACK : float = 0.3
const KNOCKBACK_FORCE : float = 400.0

# Stats
@export var health : int = 6
@export var weapon_dmg : int = 1
@export var speed : float = 150.0
@export var pushing_force : float = 20.0
@export var friction : float = FRICTION_BASE
@export var acceleration : float = 1.0

# State Machine
enum ENTITY_STATES {IDLE, MOVING, ATTACKING, KNOCKED_BACK, DEAD}
var entity_state : int = ENTITY_STATES.IDLE
var entity_last_state : int = entity_state

enum ENTITY_DIRECTION_STATES {UP, DOWN, LEFT, RIGHT}
var entity_direction_state : int = ENTITY_DIRECTION_STATES.DOWN
var entity_direction : Vector2 = Vector2.ZERO

# State Flags
var animation_change : bool = true

# Script Global
var move_direction : Vector2 = Vector2.ZERO

# Standard Functions
func _ready():
	animated_sprite_2d.play("idle_down")
	HURTBOX.connect("hit", take_dmg, 2)
	knockback_timer.connect("timeout", reset_after_knockback)

func _physics_process(_delta):
	# Accelerate Or Decelerate
	if (move_direction.length() > 0.0 && entity_state == ENTITY_STATES.MOVING):
		velocity = lerp(velocity, move_direction * speed, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	move_and_slide()

# Utility Functions
func set_entity_state(new_state : ENTITY_STATES) -> void:
	entity_last_state = entity_state
	entity_state = new_state
	animation_change = true

# Functions used by other nodes
func take_dmg(dmg : int, dir_of_atk : Vector2) -> void:
	anim_player_effects_effects.play("hurt")
	health -= dmg
	if (health < 1):
		set_entity_state(ENTITY_STATES.DEAD)
	knockback(dir_of_atk)

func knockback(knockback_vector : Vector2) -> void:
	if (entity_state != ENTITY_STATES.KNOCKED_BACK && knockback_vector.length() > 0.0):
		set_entity_state(ENTITY_STATES.KNOCKED_BACK)
		friction = FRICTION_KNOCKBACK
		velocity = velocity + (knockback_vector * KNOCKBACK_FORCE)
		knockback_timer.start()

# Functions triggered by timers
func reset_after_attack() -> void:
	if (entity_state == ENTITY_STATES.ATTACKING):
		set_entity_state(ENTITY_STATES.IDLE)

func reset_after_knockback() -> void:
	if (entity_state == ENTITY_STATES.KNOCKED_BACK):
		friction = FRICTION_BASE
		set_entity_state(ENTITY_STATES.IDLE)
