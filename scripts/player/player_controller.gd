extends CharacterBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var knockback_timer = $Knockback_Timer

# Colliders
@onready var sword_col : Area2D = $SwordPivot/Sword

@export var speed : float = 7.0
@export var pushing_force = 150.0
const FRICTION_BASE : float = 1.0
const FRICTION_KNOCKBACK : float = 0.3
const KNOCKBACK_FORCE : float = 1000.0
@export var friction : float = FRICTION_BASE
@export var acceleration : float = 1.0

enum PLAYER_STATES {IDLE, MOVING, ATTACKING, KNOCKED_BACK, HURTING, GRABBING}
var player_state : int = PLAYER_STATES.IDLE
var player_last_state : int = player_state

enum PLAYER_DIRECTION_STATES {UP, DOWN, LEFT, RIGHT}
var player_direction_state : int = PLAYER_DIRECTION_STATES.DOWN
var player_backward_direction : Vector2 = Vector2.ZERO

var can_attack : bool = true
var animation_change : bool = true

var input_dir : Vector2 = Vector2.ZERO

func _ready():
	knockback_timer.connect("timeout", reset_friction_after_knockback)
	sword_col.connect("body_entered", attack_hit, 1)
	sword_col.connect("area_entered", attack_hit, 1)

func _input(event):
	if (Input.is_action_pressed("quit")):
		get_tree().quit()
	
	if (Input.is_action_just_pressed("attack") && can_attack):
		can_attack = false
		set_player_state(PLAYER_STATES.ATTACKING)
	
	if (Input.is_action_just_pressed("reset")):
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
				set_player_state(PLAYER_STATES.MOVING)
		PLAYER_STATES.MOVING:
			if (input_dir.length() == 0.0):
				set_player_state(PLAYER_STATES.IDLE)

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

func set_player_state(new_state : PLAYER_STATES) -> void:
	player_last_state = player_state
	player_state = new_state
	animation_change = true

func player_dir_to_state() -> void:
	match player_state:
		PLAYER_STATES.IDLE:
			if (abs(input_dir.y) > abs(input_dir.x)):
				if (input_dir.y > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.DOWN
					player_backward_direction = Vector2.UP
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.UP
					player_backward_direction = Vector2.DOWN
					animation_change = true
			elif (abs(input_dir.y) < abs(input_dir.x)):
				if (input_dir.x > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.RIGHT
					player_backward_direction = Vector2.LEFT
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.LEFT
					player_backward_direction = Vector2.RIGHT
					animation_change = true
		PLAYER_STATES.MOVING:
			if (abs(input_dir.y) > abs(input_dir.x)):
				if (input_dir.y > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.DOWN
					player_backward_direction = Vector2.UP
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.UP
					player_backward_direction = Vector2.DOWN
					animation_change = true
			elif (abs(input_dir.y) < abs(input_dir.x)):
				if (input_dir.x > 0.0):
					player_direction_state = PLAYER_DIRECTION_STATES.RIGHT
					player_backward_direction = Vector2.LEFT
					animation_change = true
				else:
					player_direction_state = PLAYER_DIRECTION_STATES.LEFT
					player_backward_direction = Vector2.RIGHT
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
						anim_player.play("attack_sword_up") # Attack
					PLAYER_DIRECTION_STATES.DOWN:
						anim_player.play("attack_sword_down") # Attack
					PLAYER_DIRECTION_STATES.LEFT:
						anim_player.play("attack_sword_left") # Attack
					PLAYER_DIRECTION_STATES.RIGHT:
						anim_player.play("attack_sword_right") # Attack
			PLAYER_STATES.KNOCKED_BACK:
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

func knockback(knockback_vector : Vector2) -> void:
	set_player_state(PLAYER_STATES.KNOCKED_BACK)
	friction = FRICTION_KNOCKBACK
	velocity = velocity + (knockback_vector * KNOCKBACK_FORCE)
	knockback_timer.start()

func attack_hit(body) -> void:
	print(body)
	if (body.is_in_group("switch")):
			body.queue_free()
	if (body.is_in_group("movable")):
			body.linear_velocity = (player_backward_direction * -1) * (pushing_force * 0.25)

func reset_after_attack() -> void:
	player_state = PLAYER_STATES.IDLE
	can_attack = true
	animation_change = true

func reset_after_dash() -> void:
	player_state = PLAYER_STATES.IDLE
	animation_change = true

func reset_friction_after_knockback() -> void:
	friction = FRICTION_BASE
	player_state = PLAYER_STATES.IDLE
