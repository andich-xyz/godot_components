@tool @icon("res://assets/textures/icons/map.tres")
class_name RoomData
extends Resource


enum TemplateType {ARENA, IDLE}
@export var scene: PackedScene
@export var type: TemplateType
