@icon("res://assets/textures/icons/map_fog.tres")
class_name Room
extends Node3D


signal player_entered
@export var exits: Node3D
@export var overlap: Area3D
@onready var room_area_3d: Area3D = %RoomArea3D


func _ready() -> void:
	room_area_3d.body_entered.connect(player_entered.emit.unbind(1))


func get_exits() -> Array[Arrow]:
	var exits_array: Array[Arrow]
	for exit: Node in exits.get_children():
		if exit is Arrow:
			exits_array.append(exit)
	return exits_array
