@icon("arrow_cross.svg") @tool
class_name RootMotion
extends Node


var animation_tree: AnimationTree
var root_motion_position: Vector3
var root_motion_rotation: Quaternion
var root_motion_scale: Vector3


func _ready() -> void:
	var parent: Node = get_parent()
	if parent is not AnimationTree:
		push_warning("Parent Node should be AnimationTree.")
		return
	animation_tree = parent
	if not animation_tree.root_motion_track:
		push_warning("Property root_motion_track is not set in AnimationTree.")
		return


func _process(_delta: float) -> void:
	root_motion_position = animation_tree.get_root_motion_position()
	root_motion_rotation = animation_tree.get_root_motion_rotation()
	root_motion_scale = animation_tree.get_root_motion_scale()


func _get_configuration_warnings() -> PackedStringArray:
	var parent: Node = get_parent()
	if parent is not AnimationTree:
		return ["Parent Node should be AnimationTree."]
	return []


func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()
