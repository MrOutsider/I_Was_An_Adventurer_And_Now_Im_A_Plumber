extends CharacterBody2D

# Node Imports
@onready var anim_player_effects : AnimationPlayer = $AnimationPlayer
@onready var anim_player_effects_effects : AnimationPlayer = $AnimationPlayerEffects
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
# AI Nodes
@onready var enemy_sight : Area2D = $EnemySight
@onready var enemy_sight_range : CollisionShape2D = $EnemySight/EnemySightRange
@onready var enemy_ray_cast : RayCast2D = $RayCasts/EnemyRayCast
@onready var wall_up_ray_cast : RayCast2D = $RayCasts/WallRayCasts/WallUpRayCast
@onready var wall_down_ray_cast : RayCast2D = $RayCasts/WallRayCasts/WallDownRayCast
@onready var wall_left_ray_cast : RayCast2D = $RayCasts/WallRayCasts/WallLeftRayCast
@onready var wall_right_ray_cast : RayCast2D = $RayCasts/WallRayCasts/WallRightRayCast
# Modules
@export var HURTBOX : Area2D
# Timers
@onready var ai_tick : Timer = $AI_Tick
@onready var ai_wander_timer : Timer = $AI_WanderTimer
@onready var knockback_timer : Timer = $KnockbackTimer

# Constants
const FRICTION_BASE : float = 1.0
const FRICTION_KNOCKBACK : float = 0.3
const KNOCKBACK_FORCE : float = 400.0

# AI Flags
@export var hostile : bool = false
@export var wander : bool = false
@export var follow : bool = false # Navmesh following
@export var enemy_group : String = "player"

# Stats
@export var max_health : int = 6
@export var health : int = 6
@export var damage : int = 1
@export var speed : float = 150.0
@export var pushing_force : float = 1000.0
@export var friction : float = FRICTION_BASE
@export var acceleration : float = 1.0

# State Machine
enum ENTITY_STATES {IDLE, MOVING, ATTACKING, KNOCKED_BACK, DEAD}
var entity_state : int = ENTITY_STATES.IDLE
var entity_last_state : int = entity_state

enum ENTITY_DIRECTION_STATES {UP, DOWN, LEFT, RIGHT}
var entity_direction_state : int = ENTITY_DIRECTION_STATES.DOWN
var forward_direction : Vector2 = Vector2.ZERO

# State Flags
var animation_change : bool = true

# Script Global
var move_direction : Vector2 = Vector2.ZERO
var enemy_node : Node2D = null

# Standard Functions
func _ready():
	# Init sprite animations
	animated_sprite_2d.play("idle_down")
	# Reactions
	HURTBOX.connect("hit", take_dmg, 2)
	enemy_sight.area_entered.connect(area_entered_vison, 1)
	# Timers
	ai_wander_timer.timeout.connect(ai_wander)
	ai_tick.timeout.connect(ai_aggro)
	knockback_timer.timeout.connect(reset_after_knockback)

func _physics_process(_delta):
	if (move_direction.length() > 0.0 && entity_state == ENTITY_STATES.MOVING):
		velocity = lerp(velocity, move_direction * speed, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	if (move_and_slide()):
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if (col.get_collider() is RigidBody2D):
				if (col.get_collider().is_in_group("movable")):
					col.get_collider().apply_force((col.get_normal() * pushing_force)* -1.0)
					velocity = col.get_collider().linear_velocity

# Utility Functions
func set_entity_state(new_state : ENTITY_STATES) -> void:
	entity_last_state = entity_state
	entity_state = new_state
	animation_change = true

func area_entered_vison(area : Node2D) -> void:
	if (area.is_in_group(enemy_group)):
		enemy_node = area
		set_entity_state(ENTITY_STATES.MOVING)

func ai_wander() -> void:
	# TODO: Pick location and Navmesh to it.
	if (wander && enemy_node == null):
		if (entity_state == ENTITY_STATES.IDLE || entity_state == ENTITY_STATES.MOVING):
			var rand_i = randi_range(0,5)
			match rand_i:
				0:
					set_entity_state(ENTITY_STATES.IDLE)
				1:
					set_entity_state(ENTITY_STATES.MOVING)
				2:
					move_direction = Vector2.UP
				3:
					move_direction = Vector2.DOWN
				4:
					move_direction = Vector2.LEFT
				5:
					move_direction = Vector2.RIGHT

func ai_aggro() -> void:
	if (hostile && enemy_node != null):
		var enemy_dir = enemy_node.global_position - global_position
		var dist_to_enemy = enemy_dir.length()
		enemy_ray_cast.target_position = enemy_dir
		if (enemy_ray_cast.get_collider() == enemy_node):
			move_direction = enemy_dir.normalized()
		else:
			enemy_node = null
			for i in enemy_sight.get_overlapping_areas():
				if(i.is_in_group(enemy_group)):
					enemy_node = i

# Functions used by other nodes
func take_dmg(dmg : int, dir_of_atk : Vector2) -> void:
	anim_player_effects_effects.play("hurt")
	health -= dmg
	if (health < 1):
		health = 0
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
