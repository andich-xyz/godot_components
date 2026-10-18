@tool
class_name Ailment
extends Resource


@export var name: StringName
@export var icon: Texture2D
@export var scene: PackedScene
@export var overlay_material: Material
@export var instance_on_bones_mesh: Mesh
@export_multiline() var description: String


func _get_custom_preview_texture() -> Texture2D:
	return icon
