extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var hurt_animations = $HurtAnimations
@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	animated_sprite_2d.play("idle_down")
	var rot_t : Timer = Timer.new()
	add_child(rot_t)
	rot_t.wait_time = 1.0
	rot_t.start()
	rot_t.connect("timeout", change_face)

func hurt() -> void:
	hurt_animations.play("hurt")

func change_face() -> void:
	var i = randi_range(0, 4)
	match i:
		0:
			animation_player.play("idle_down")
		1:
			animation_player.play("idle_up")
		2:
			animation_player.play("idle_left")
		3:
			animation_player.play("idle_right")
