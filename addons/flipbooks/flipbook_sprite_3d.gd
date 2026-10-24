@tool
class_name FlipbookSprite3D
extends MeshInstance3D


signal started
signal finished
@export var flipbook: Texture2D:
	set = set_flipbook
@export var rows: int = 8:
	set = set_rows
@export var columns: int = 8:
	set = set_columns
@export var frame_rate: int = 60:
	set = set_frame_rate
@export var speed: float = 1.0:
	set = set_speed
@export var billboard: BaseMaterial3D.BillboardMode:
	set = set_billboard
@export_group("Frame Controls")
@export var overwrite_frame: bool = false:
	set = set_overwrite_frame
@export var current_frame: int = 0:
	set = set_current_frame
@export var real_time: bool = false:
	set = set_real_time
@onready var _material: ShaderMaterial = mesh.surface_get_material(0):
	set = set_material
var _tween: Tween
var _property_tweener: PropertyTweener


func _ready() -> void:
	current_frame = 0
	started.emit()


#region getters/setters
func set_flipbook(_flipbook: Texture2D) -> void:
	flipbook = _flipbook
	if _material:
		_material.set_shader_parameter("flipbook_texture", flipbook)


func set_rows(_rows: int) -> void:
	rows = _rows
	if _material:
		_material.set_shader_parameter("rows", rows)


func set_columns(_columns: int) -> void:
	columns = _columns
	if _material:
		_material.set_shader_parameter("columns", columns)


func set_frame_rate(_frame_rate: int) -> void:
	frame_rate = _frame_rate
	if _material:
		_material.set_shader_parameter("frame_rate", frame_rate)


func set_speed(_speed: float) -> void:
	speed = _speed
	if _material:
		_material.set_shader_parameter("speed", speed)


func set_overwrite_frame(_overwrite_frame: int) -> void:
	overwrite_frame = _overwrite_frame
	if _material:
		_material.set_shader_parameter("overwrite_frame", overwrite_frame)
	notify_property_list_changed()
	if not overwrite_frame and _tween:
		_tween.kill()
	else:
		real_time = real_time


func set_current_frame(_current_frame: int) -> void:
	current_frame = _current_frame % (rows * columns)
	if _material:
		_material.set_shader_parameter("current_frame", current_frame)
	if _current_frame == 0:
		started.emit()


func set_real_time(_real_time: int) -> void:
	real_time = _real_time
	if not overwrite_frame:
		return
	if real_time:
		_tween = create_tween()
		#_tween.set_loops()
		_property_tweener = _tween.tween_property(
			self,
			^"current_frame",
			rows * columns - 1,
			frame_rate / 60.0 * speed
			).set_trans(Tween.TRANS_LINEAR).from(0)
		#_tween.loop_finished.connect(finished.emit.unbind(1))
		_tween.finished.connect(finished.emit)
	elif _tween and not real_time:
		_tween.kill()


func set_billboard(_billboard: BaseMaterial3D.BillboardMode) -> void:
	billboard = _billboard
	if _material:
		_material.set_shader_parameter("billboard", billboard)


func set_material(__material: ShaderMaterial) -> void:
	_material = __material
	_material.set_shader_parameter("flipbook_texture", flipbook)
	_material.set_shader_parameter("rows", rows)
	_material.set_shader_parameter("columns", columns)
	_material.set_shader_parameter("frame_rate", frame_rate)
	_material.set_shader_parameter("speed", speed)
	_material.set_shader_parameter("overwrite_frame", overwrite_frame)
	_material.set_shader_parameter("current_frame", current_frame)
#endregion
