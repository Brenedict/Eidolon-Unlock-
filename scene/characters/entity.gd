class_name Entity
extends PlatformerCharacter2D

func _ready() -> void:
	animated_sprite.play(animations.walk)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)



