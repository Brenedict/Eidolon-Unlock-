class_name TransitionScreen
extends CanvasLayer

signal finished

@export var color_rect : ColorRect
@export var animation_player : AnimationPlayer

func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	_intro_transition()

func _on_animation_finished(anim_name : StringName):
	if anim_name == "fade_to_black" or anim_name == "intro_fade":
		finished.emit()
		if anim_name == "fade_to_black":
			animation_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		color_rect.visible = false


func transition():
	animation_player.play("fade_to_black")
	color_rect.visible = true

func _intro_transition():
	color_rect.visible = true
	animation_player.play("intro_fade")

