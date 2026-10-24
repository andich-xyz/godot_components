class_name WASDControls
extends Node


@export var active: bool = true:
	set = set_active
var direction: Vector2 = Vector2.ZERO
var smooth_direction: Vector2 = Vector2.ZERO
@export var smooth: bool = false
@export var blend_time: float = 0.1
@export_group("Input Actions")
@export var action_left: StringName = &"Left"
@export var action_right: StringName = &"Right"
@export var action_forward: StringName = &"Forward"
@export var action_backward: StringName = &"Backward"
var _smooth_tween: Tween
var _smooth_tweener: PropertyTweener


func _input(_event: InputEvent) -> void:
	if not active:
		return
	var input_vector: Vector2 = -Input.get_vector(action_left, action_right, action_forward, action_backward)
	if smooth:
		if _smooth_tween:
			_smooth_tween.kill()
		_smooth_tween = create_tween()
		_smooth_tweener = _smooth_tween.tween_property(self, "smooth_direction", input_vector, blend_time)
	direction = input_vector


func set_active(_active: bool) -> void:
	active = _active
	if not active:
		direction = Vector2.ZERO
		smooth_direction = Vector2.ZERO
