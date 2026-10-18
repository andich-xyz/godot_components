@tool
class_name Stat
extends Resource


@export var name: StringName
@export var icon: Texture2D
@export_multiline() var description: String


func _get_custom_preview_texture() -> Texture2D:
	return icon
