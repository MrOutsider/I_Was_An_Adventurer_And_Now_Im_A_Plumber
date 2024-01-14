extends CharacterBody2D

# Node Imports
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var anim_player_effects : AnimationPlayer = $AnimationPlayerEffects
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
# AI Nodes
@onready var enemy_sight : Area2D = $EnemySight
@onready var enemy_sight_area : CollisionShape2D = $EnemySight/EnemySightArea
@onready var enemy_ray_cast : RayCast2D = $RayCasts/EnemyRayCast
@onready var wall_up_ray_cast : RayCast2D = $RayCasts/WallRayCasts/WallUpRayCast
@onready var wall_down_ray_cast : RayCast2D = $RayCasts/WallRayCasts/WallDownRayCast
@onready var wall_left_ray_cast : RayCast2D = $RayCasts/WallRayCasts/WallLeftRayCast
@onready var wall_right_ray_cast : RayCast2D = $RayCasts/WallRayCasts/WallRightRayCast
# Modules
@onready var visible_on_screen_enabler_2d = $VisibleOnScreenEnabler2D
@export var HURTBOX : Area2D
@export var HITBOX : Area2D
# Timers
@onready var ai_tick : Timer = $AI_Tick
@onready var ai_wander_timer : Timer = $AI_WanderTimer
@onready var attack_speed_timer = $AttackSpeedTimer
@onready var knockback_timer : Timer = $KnockbackTimer
# SFX
@onready var hurt_sound = $HurtSound

# Constants
const FRICTION_BASE : float = 1.0
const FRICTION_KNOCKBACK : float = 0.3
const KNOCKBACK_FORCE : float = 400.0

# AI Flags
@export var hostile : bool = false
@export var wander : bool = false
@export var chase : bool = false ## NAVMESH to last known location
@export var enemy_group : String = "player"
@export var can_move_movables : bool = false

# Stats
@export var max_health : int = 2
@export var health : int = 2
@export var damage : int = 1
@export var vision_distance : float = 20.0
@export var speed : float = 50.0
@export var pushing_force : float = 50.0 ## Force when moving against "moveable" group.
@export var friction : float = FRICTION_BASE
@export var acceleration : float = 1.0

# State Machine
enum ENTITY_STATES {IDLE, MOVING, ATTACKING, KNOCKED_BACK, DEAD}
var entity_state : ENTITY_STATES = ENTITY_STATES.IDLE
var entity_last_state : ENTITY_STATES = entity_state

enum AI_STATES {IDLE, AGRO, HUNT, DEAD}
var ai_state : AI_STATES

enum ENTITY_DIRECTION_STATES {UP, DOWN, LEFT, RIGHT}
var entity_direction_state : ENTITY_DIRECTION_STATES = ENTITY_DIRECTION_STATES.DOWN
var forward_direction : Vector2 = Vector2.ZERO

# State Flags
var animation_change : bool = true

# Script Global
var move_direction : Vector2 = Vector2.ZERO
var enemy_node : Node2D = null
var enemy_in_range : bool = false
var last_known_enemy_location : Vector2 = Vector2.ZERO

# Standard Functions
func _ready():
	visible_on_screen_enabler_2d.show()
	if (health > max_health): health = max_health
	# Init sprite animations
	animated_sprite_2d.play("idle_down")
	# Set Stats
	enemy_sight_area.shape.radius = vision_distance * 10
	# Reactions
	HURTBOX.hit.connect(take_dmg, 2)
	HITBOX.area_entered.connect(hitbox_hit, 1)
	HITBOX.body_entered.connect(hitbox_hit, 1)
	HITBOX.area_exited.connect(hitbox_left, 1)
	HITBOX.body_exited.connect(hitbox_left, 1)
	# Timers
	ai_wander_timer.timeout.connect(ai_wander)
	ai_tick.timeout.connect(ai_look_for_enemy)
	ai_tick.timeout.connect(ai_aggro)
	attack_speed_timer.timeout.connect(melee_atk)
	knockback_timer.timeout.connect(reset_after_knockback)

func _process(_delta):
	animate_sprite()

func _physics_process(_delta):
	if (move_direction.length() > 0.0 && entity_state == ENTITY_STATES.MOVING):
		velocity = lerp(velocity, move_direction * speed, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	if (move_and_slide()):
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if (col.get_collider() is RigidBody2D):
				if (col.get_collider().is_in_group("movable") && can_move_movables):
					col.get_collider().apply_force((col.get_normal() * pushing_force)* -1.0)
					velocity = col.get_collider().linear_velocity

# Utility Functions
func set_entity_state(new_state : ENTITY_STATES) -> void:
	entity_last_state = entity_state
	entity_state = new_state
	animation_change = true
	match entity_state:
		ENTITY_STATES.DEAD:
			set_ai_state(AI_STATES.DEAD)
			set_collision_layer_value(2, false)
			set_collision_mask_value(2, false)
			move_direction = Vector2.ZERO
			hurt_sound.pitch_scale = 0.8
			anim_player_effects.play("death")
			animation_change = true

func set_ai_state(new_state : AI_STATES) -> void:
	ai_state = new_state

func entity_dir_to_state() -> void:
	if (abs(move_direction.y) > abs(move_direction.x)):
		if (move_direction.y > 0.0):
			forward_direction = Vector2.DOWN
		else:
			forward_direction = Vector2.UP
	elif (abs(move_direction.y) < abs(move_direction.x)):
		if (move_direction.x > 0.0):
			forward_direction = Vector2.RIGHT
		else:
			forward_direction = Vector2.LEFT

func animate_sprite() -> void:
	if (animation_change):
		entity_dir_to_state()
		match entity_state:
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
			ENTITY_STATES.DEAD:
				anim_player.play("death")
		if (entity_state == ENTITY_STATES.IDLE ||
		entity_state == ENTITY_STATES.KNOCKED_BACK):
			match forward_direction:
					Vector2.UP:
						anim_player.play("idle_up")
					Vector2.DOWN:
						anim_player.play("idle_down")
					Vector2.LEFT:
						anim_player.play("idle_left")
					Vector2.RIGHT:
						anim_player.play("idle_right")
		animation_change = false

func ai_wander() -> void:
	if (wander && ai_state == AI_STATES.IDLE):
		if (entity_state == ENTITY_STATES.IDLE || entity_state == ENTITY_STATES.MOVING):
			var rand_i = randi_range(0,5)
			match rand_i:
				0:
					set_entity_state(ENTITY_STATES.IDLE)
				1:
					set_entity_state(ENTITY_STATES.MOVING)
				2:
					move_direction = Vector2.UP
					animation_change = true
				3:
					move_direction = Vector2.DOWN
					animation_change = true
				4:
					move_direction = Vector2.LEFT
					animation_change = true
				5:
					move_direction = Vector2.RIGHT
					animation_change = true

func ai_look_for_enemy() -> void:
	if (ai_state == AI_STATES.IDLE && hostile):
		if (enemy_sight.has_overlapping_areas()):
			for i in enemy_sight.get_overlapping_areas():
				if (i.is_in_group(enemy_group)):
					if (i.get_parent().entity_state != ENTITY_STATES.DEAD):
						var enemy_dir = i.global_position - global_position
						enemy_ray_cast.target_position = enemy_dir
						var ray_i = enemy_ray_cast.get_collider()
						if (ray_i != null):
							if (ray_i.is_in_group(enemy_group)):
								enemy_node = i
								set_ai_state(AI_STATES.AGRO)
								break

func ai_aggro() -> void:
	if (ai_state == AI_STATES.AGRO && enemy_node != null):
		var enemy_dir = enemy_node.global_position - global_position
		var enemy_distance = enemy_dir.length()
		enemy_ray_cast.target_position = enemy_dir
		if (enemy_ray_cast.get_collider() == enemy_node):
			if (entity_state == ENTITY_STATES.IDLE): set_entity_state(ENTITY_STATES.MOVING)
			last_known_enemy_location = enemy_node.global_position
			move_direction = enemy_dir.normalized()
			animation_change = true
		elif(enemy_distance > vision_distance):
			enemy_node = null
	elif (ai_state != AI_STATES.DEAD):
		if (chase):
			set_ai_state(AI_STATES.HUNT)
		else:
			set_ai_state(AI_STATES.IDLE)

func hitbox_hit(body : CollisionObject2D) -> void:
	if (enemy_node != null):
		if (body == enemy_node && attack_speed_timer.time_left == 0):
			enemy_node.take_dmg(damage, (enemy_node.global_position - global_position).normalized())
			enemy_in_range = true
			attack_speed_timer.start()

func hitbox_left(body : CollisionObject2D) -> void:
	if (enemy_node != null):
		if (body == enemy_node):
			enemy_in_range = false

func melee_atk() -> void:
	if (enemy_in_range && enemy_node != null && entity_state != ENTITY_STATES.DEAD):
		enemy_node.take_dmg(damage, (enemy_node.global_position - global_position).normalized())
		if (enemy_node.get_parent().entity_state == ENTITY_STATES.DEAD):
			enemy_node = null
		else:
			attack_speed_timer.start()

# Functions used by other nodes
func take_dmg(dmg : int, dir_of_atk : Vector2) -> void:
	hurt_sound.play()
	if (entity_state != ENTITY_STATES.DEAD):
		anim_player_effects.play("hurt")
		health -= dmg
		if (health < 1 && entity_state != ENTITY_STATES.DEAD):
			health = 0
			set_entity_state(ENTITY_STATES.DEAD)
	knockback(dir_of_atk)

func knockback(knockback_vector : Vector2) -> void:
	if (entity_state != ENTITY_STATES.KNOCKED_BACK && knockback_vector.length() > 0.0):
		if (entity_state != ENTITY_STATES.DEAD):
			set_entity_state(ENTITY_STATES.KNOCKED_BACK)
			move_direction = Vector2.ZERO
		friction = FRICTION_KNOCKBACK
		velocity = velocity + (knockback_vector * KNOCKBACK_FORCE)
		knockback_timer.start()

# Functions triggered by timers
func reset_after_attack() -> void:
	if (entity_state == ENTITY_STATES.ATTACKING):
		set_entity_state(ENTITY_STATES.IDLE)

func reset_after_knockback() -> void:
	friction = FRICTION_BASE
	if (entity_state == ENTITY_STATES.KNOCKED_BACK):
		set_entity_state(ENTITY_STATES.IDLE)
