extends Area2D

signal hit(dmg : int, dir_of_atk : Vector2)

func take_dmg(dmg : int, dir_of_atk : Vector2) -> void:
	hit.emit(dmg, dir_of_atk)
