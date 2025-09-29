extends Node2D

@export var character : PlatformerCharacter2D:
	set(value):
		if is_instance_valid(character):
			character.direction_changed.disconnect(_on_direction_changed)

		character = value

		if is_instance_valid(character):
			character.direction_changed.connect(_on_direction_changed)

func _on_direction_changed(p_direction : Vector2):
	if p_direction.x == 0:
		return

	scale.x = abs(scale.x) * sign(p_direction.x)
