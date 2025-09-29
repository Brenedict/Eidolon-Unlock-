extends Node2D

@export var zipline : Path2D

func _on_ladders_body_entered(_body: Node2D) -> void:
	_body.climbing = true

func _on_ladders_body_exited(_body: Node2D) -> void:
	_body.climbing = false

func _on_zipline_area_body_entered(_body: Node2D) -> void:
	var point = zipline.get_child(0)
	if point is PathFollow2D and point.progress_ratio == 1.0:
		return

	var path_points = zipline.curve.get_baked_points()
	var length = path_points[0].distance_to(path_points[-1])

	var start_pos = _body.global_position - (zipline.global_position + path_points[0])

	point.progress_ratio = start_pos.x / length
	_body.global_position = point.global_position + Vector2(0, 20.0)
	_body.reparent(point)
	_body.zipline = true
