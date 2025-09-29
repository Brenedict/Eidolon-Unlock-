class_name Player
extends PlatformerCharacter2D

@export var idle_timer : Timer
@export var raycast : RayCast2D
@export_range(0, 500, 0.2, "or_greater") var walk_speed : float = 100.0
@export_range(0, 500, 0.2, "or_greater") var run_speed : float = 200.0
@export_range(0, 500, 0.2, "or_greater") var jump_force : float = 300.0

var run : bool = false
var climbing : bool = false
var interact : bool = false

func _ready():
	animated_sprite.play(animations.idle_2)

func _physics_process(delta: float) -> void:
	var move_speed = run_speed if _can_run() else walk_speed
	velocity.x = direction.x * move_speed

	if not climbing:
		_apply_gravity(delta)
	else:
		velocity.y = direction.y * walk_speed

	move_and_slide()
	_process_pushable_objects(move_speed)
	_process_animations()

func _process_pushable_objects(move_speed : float) -> void:
	var object = raycast.get_collider()

	if object and interact:
		var push_force = move_speed * direction.x
		var pull_force = push_force * 1.25

		# Direction Vector
		var object_direction_sign = sign(object.position.x - position.x)
		var movement_direction_sign = sign(direction.x)
		print(object_direction_sign == movement_direction_sign)
		object.linear_velocity.x =  push_force if object_direction_sign == movement_direction_sign else pull_force

func _process_animations() -> void:
	if not is_on_floor():
		if climbing:
			play_animation(animations.climb)
		elif current_animation() != animations.fall and current_animation() != animations.jump:
			play_animation(animations.fall)

		_reset_idle_timer()
		return

	if abs(direction.x) > 0.0:
		play_animation(animations.run if _can_run() else animations.walk)
		_reset_idle_timer()
		return

	_handle_idle_animation()

func _reset_idle_timer():
	if !idle_timer.paused:
		idle_timer.start()
		idle_timer.paused = true
	
func _can_run():
	return run and not interact

func _handle_idle_animation():
	if current_animation() == animations.idle_2:
		return

	play_animation(animations.idle_1)
	if idle_timer.time_left <= 0:
		play_animation(animations.idle_2)
	elif idle_timer.paused or idle_timer.is_stopped():
		idle_timer.paused = false
		idle_timer.start()


# Makes the character jump if possible
func try_jump() -> bool:
	if is_on_floor():
		_jump()
		return true
	
	return false

# Execute a ground jump
func _jump() -> void:
	velocity.y -= jump_force
	stop_animation()
	play_animation(animations.jump)


func _on_animated_sprite_2d_animation_finished() -> void:
	if current_animation() == animations.jump:
		play_animation(animations.fall)

func _on_ladders_body_entered(_body: Node2D) -> void:
	climbing = true

func _on_ladders_body_exited(_body: Node2D) -> void:
	climbing = false
