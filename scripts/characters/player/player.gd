class_name Player
extends PlatformerCharacter2D

@export var spawn_point : Marker2D
@export var idle_timer : Timer
@export var raycast : RayCast2D
@export var camera : Camera2D
@export_range(0, 500, 0.2, "or_greater") var walk_speed : float = 100.0
@export_range(0, 500, 0.2, "or_greater") var run_speed : float = 200.0
@export_range(0, 500, 0.2, "or_greater") var jump_force : float = 300.0

@export var spawn_at_start : bool = true

var run : bool = false
var climbing : bool = false
var interact : bool = false
var zipline : bool = false

func _ready():
	if spawn_point and spawn_at_start:
		global_position = spawn_point.global_position

	_get_remote_transform().remote_path = camera.get_path()
	animated_sprite.play(animations.idle_2)

func _get_remote_transform() -> RemoteTransform2D:
	for child in get_children():
		if child is RemoteTransform2D:
			return child
	
	return null


func _physics_process(delta: float) -> void:
	if _try_zipline(delta):
		return

	var move_speed = run_speed if _can_run() else walk_speed
	velocity.x = direction.x * move_speed

	if not climbing:
		_apply_gravity(delta)
	else:
		velocity.y = direction.y * walk_speed

	move_and_slide()
	_process_one_way_collisions()
	_process_pushable_objects(move_speed)
	_process_animations()

func _process_one_way_collisions():
	if direction.y <= 0:
		return

	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var shape = get_slide_collision(i).get_collider_shape()
			if shape and shape.one_way_collision:
				position.y += 1

func _try_zipline(delta: float) -> bool:
	if not zipline:
		return false

	var parent = get_parent()
	if not parent is PathFollow2D:
		return false

	if parent.progress_ratio < 1.0:
		return _advance_on_zipline(parent, delta)

	_detach_from_zipline()
	return false


func _advance_on_zipline(parent: PathFollow2D, delta: float) -> bool:
	play_animation(animations.climb)
	parent.progress_ratio += 0.2 * delta
	return true


func _detach_from_zipline() -> void:
	zipline = false
	reparent(get_tree().root.get_child(0))
	_get_remote_transform().remote_path = camera.get_path()
	global_rotation = 0

func _process_pushable_objects(move_speed : float) -> void:
	var object = raycast.get_collider()

	if not object:
		interact = false

	if interact:
		play_animation(animations.interact)
		var push_force = move_speed * direction.x
		var pull_force = push_force * 1.25

		# Direction Vector
		var object_direction_sign = sign(object.global_position.x - global_position.x)
		var movement_direction_sign = sign(direction.x)
		print(object_direction_sign == movement_direction_sign)
		object.linear_velocity.x =  push_force if object_direction_sign == movement_direction_sign else pull_force

func _process_animations() -> void:
	if interact:
		return

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
