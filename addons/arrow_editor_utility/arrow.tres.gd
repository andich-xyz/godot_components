@tool @icon("res://assets/textures/icons/arrow_right.png")
class_name Arrow extends CSGCombiner3D


@export var color: Color = Color.DARK_RED:
	set(value):
		color = value
		set_arrow_color(value)
@export_range(0.01, 5.0, 0.01, "or_greater") var size: float = 1.0:
	set(value):
		size = value
		set_arrow_size()
@export_range(0.0, 5.0, 0.01) var radius: float = 0.1:
	set(value):
		radius = value
		set_arrow_size()
@onready var stem: CSGCylinder3D = $Stem
@onready var tip: CSGCylinder3D = $Tip


func _ready() -> void:
	set_arrow_size()


func set_arrow_color(new_color: Color) -> void:
	var material: StandardMaterial3D = material_override
	material.albedo_color = new_color


func set_arrow_size() -> void:
	if not (is_instance_valid(tip) and is_instance_valid(stem)):
		return
	tip.radius = size * radius
	tip.height = tip.radius * 2
	tip.position.z = -size + tip.height / 2.0
	stem.height = size - tip.height
	stem.position.z = -stem.height / 2.0
	stem.radius = size * radius * 0.25
