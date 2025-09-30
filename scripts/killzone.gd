class_name KillZone
extends Area2D

@export var transition_screen : TransitionScreen
@export var player : Player
@export var spawn_point : Marker2D

func _on_body_entered(_body: Node2D) -> void:
	print("You Died!")
	_body.set_physics_process(false)
	transition_screen.transition()
	await transition_screen.finished
	player.global_position = spawn_point.global_position
	_body.set_physics_process(true)



