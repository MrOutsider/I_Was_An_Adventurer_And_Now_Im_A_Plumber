extends CharacterBody2D

# Node Imports
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var anim_player_attacks : AnimationPlayer = $AnimationPlayerAttacks
@onready var anim_player_effects : AnimationPlayer = $AnimationPlayerEffects
@onready var player_sprite : AnimatedSprite2D = $PlayerSprite
@onready var canvas_layer = $Camera2D/CanvasLayer
@onready var hurt_sound : AudioStreamPlayer2D = $HurtSound

# Modules
@export var HURTBOX : Area2D
# -> Timers
@onready var knockback_timer : Timer = $KnockbackTimer
# -> Colliders
@onready var interact_ray : RayCast2D = $InteractRay
@export var sword_col : Area2D
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
enum ENTITY_STATES {IDLE, MOVING, ATTACKING, KNOCKED_BACK, DEAD}
var entity_state : ENTITY_STATES = ENTITY_STATES.IDLE
var entity_last_state : ENTITY_STATES = entity_state
@export var forward_direction : Vector2 = Vector2.ZERO
var forward_direction_last : Vector2 = forward_direction

# State Flags
var animation_change : bool = true

# Script Global
var interactible_node : Node2D = null
var input_dir : Vector2 = Vector2.ZERO
var last_position : Vector2 = global_position

# DEV
@export var end : Node = null
func upd_hp(value : int) -> void:
	health = value

func reset() -> void:
	end.start_new_game()
# DEV


# Standard Functions
func _ready():
	# DEV
	PLAYER.hp_change.connect(upd_hp, 1)
	PLAYER.set_hp(health)
	# DEV
	canvas_layer.show()
	player_sprite.play("idle_down") # Start Sprite Animations 
	# Connecting Signals
	HURTBOX.hit.connect(take_dmg, 2)
	knockback_timer.timeout.connect(reset_after_knockback)
	sword_col.area_entered.connect(attack_hit, 1)
	sword_col.body_entered.connect(attack_hit, 1)
	anim_player_attacks.animation_finished.connect(reset_after_attack, 1)
	call_deferred("set_player_state", ENTITY_STATES.IDLE)

func _input(_event):
	if (Input.is_action_just_pressed("action")):
		if (interactible_node != null):
			interact_with_interactible()

func _process(_delta):
	process_inputs()
	animate_sprite()

func _physics_process(_delta):
	scan_for_interactables()
	last_position = global_position
	if (input_dir.length() > 0.0 && entity_state == ENTITY_STATES.MOVING):
		velocity = lerp(velocity, input_dir * speed, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	move_and_slide()

# Utility Functions
func process_inputs() -> void:
	if (entity_state == ENTITY_STATES.IDLE || entity_state == ENTITY_STATES.MOVING):
		input_dir.x = Input.get_action_raw_strength("move_right") - Input.get_action_raw_strength("move_left")
		input_dir.y = Input.get_action_raw_strength("move_down") - Input.get_action_raw_strength("move_up")
		if (input_dir.length() > 1.0):
			input_dir = input_dir.normalized()
		if (input_dir.length() < 0.5):
			input_dir = Vector2.ZERO
		player_dir_to_state()
		
		if (Input.is_action_just_pressed("attack")):
			set_player_state(ENTITY_STATES.ATTACKING)
	
	match entity_state:
		ENTITY_STATES.IDLE:
			if (input_dir.length() > 0.0):
				set_player_state(ENTITY_STATES.MOVING)
		ENTITY_STATES.MOVING:
			if (input_dir.length() == 0.0):
				set_player_state(ENTITY_STATES.IDLE)

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
		match entity_state:
			ENTITY_STATES.IDLE:
				match forward_direction:
					Vector2.UP:
						anim_player.play("idle_up")
					Vector2.DOWN:
						anim_player.play("idle_down")
					Vector2.LEFT:
						anim_player.play("idle_left")
					Vector2.RIGHT:
						anim_player.play("idle_right")
			ENTITY_STATES.KNOCKED_BACK:
				match forward_direction:
					Vector2.UP:
						anim_player.play("idle_up")
					Vector2.DOWN:
						anim_player.play("idle_down")
					Vector2.LEFT:
						anim_player.play("idle_left")
					Vector2.RIGHT:
						anim_player.play("idle_right")
			ENTITY_STATES.MOVING:
				match forward_direction:
					Vector2.UP:
						anim_player.play("move_up")
					Vector2.DOWN:
						anim_player.play("move_down")
					Vector2.LEFT:
						anim_player.play("move_left")
					Vector2.RIGHT:
						anim_player.play("move_right")
			ENTITY_STATES.ATTACKING:
				if (forward_direction == Vector2.ZERO):
					forward_direction = Vector2.DOWN
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

func set_player_state(new_state : ENTITY_STATES) -> void:
	entity_last_state = entity_state
	entity_state = new_state
	animation_change = true

func scan_for_interactables() -> void:
	if (interact_ray.is_colliding()):
		var body : CollisionObject2D = interact_ray.get_collider()
		if (body != null):
			if (interactible_node != null):
				if (interactible_node != body.get_parent()): interactable_lose_focus()
			if (body.is_in_group("interactable")):
				if (body.get_parent().can_use):
					if (interactible_node != null):
						interactable_lose_focus()
					interactible_node = body.get_parent()
					interactible_node.focus()
	elif (interactible_node != null):
		interactable_lose_focus()

func interactable_lose_focus() -> void:
	interactible_node.lose_focus()
	interactible_node = null

func interact_with_interactible() -> void:
	if (interactible_node.is_in_group("placeable")):
		interactible_node.use()
	if (interactible_node.is_in_group("switch")):
		interactible_node.flip_switch()

# Function for when collider collides
func attack_hit(body : CollisionObject2D) -> void:
	if (body == self || body == HURTBOX):
		return
	# Raycast to see if wall is between player and body hit.
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
	# Bounc off of walls when attacking. - Needs custom Area2d with walls layer enabled.
	if (body.get_collision_layer_value(1)):
		knockback(forward_direction * -1.0)

# Functions triggered by timers
func reset_after_attack(anim : String) -> void:
	if (anim == "attack_sword_down" ||
	anim == "attack_sword_up" ||
	anim == "attack_sword_left" ||
	anim == "attack_sword_right"):
		set_player_state(ENTITY_STATES.IDLE)

func reset_after_knockback() -> void:
	friction = FRICTION_BASE
	if (entity_state == ENTITY_STATES.KNOCKED_BACK):
		set_player_state(ENTITY_STATES.IDLE)

# Functions used by other nodes
func take_dmg(dmg : int, dir_of_atk : Vector2) -> void:
	health -= dmg
	var i = randf_range(0.5, 0.75)
	hurt_sound.pitch_scale = i
	hurt_sound.play()
	anim_player_effects.play("hurt")
	if (health < 1):
		health = 0
		set_player_state(ENTITY_STATES.DEAD)
		# DEV
		reset()
		# DEV
	
	PLAYER.set_hp(health)
	knockback(dir_of_atk)

func knockback(knockback_vector : Vector2) -> void:
	if (entity_state != ENTITY_STATES.KNOCKED_BACK && knockback_vector.length() > 0.0):
		set_player_state(ENTITY_STATES.KNOCKED_BACK)
		friction = FRICTION_KNOCKBACK
		velocity = velocity + (knockback_vector * KNOCKBACK_FORCE)
		knockback_timer.start()
