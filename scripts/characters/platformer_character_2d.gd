class_name PlatformerCharacter2D
extends CharacterBody2D

@export var animated_sprite : AnimatedSprite2D
@export var animations : CharacterAnimations2D
signal direction_changed(direction : Vector2)

var direction : Vector2 :
	set(value):
		if direction == value:
			return

		direction = value
		direction_changed.emit(direction)

func play_animation(animation : StringName) -> void:
	animated_sprite.play(animation)

func stop_animation() -> void:
	animated_sprite.stop()

func current_animation() -> StringName:
	return animated_sprite.animation

func _apply_gravity(delta : float) -> void:
	if is_on_floor():
		return

	var gravity = get_gravity()
	velocity += gravity * delta
