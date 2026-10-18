@icon("res://assets/textures/icons/world.tres")
class_name Floor
extends Node3D


signal loaded
const FAILSAFE_TIME: float = 3.0
@export var initial_room: Room
@export var rooms: Array[RoomData]
@export var dead_ends: Array[PackedScene]
@export var room_amount: int = 10
@export var room_collection: Node3D
var timer: Timer
var exits: Array[Arrow]


func _ready() -> void:
	exits = initial_room.get_exits()
	_set_up_timer()
	spawn_room()
	place_dead_ends()
	timer.queue_free()
	loaded.emit()


func spawn_room() -> void:
	if room_amount < 1:
		return
	var current_exit: Arrow
	var current_room_resource: RoomData
	current_exit = exits.get(randi_range(0, exits.size() - 1))
	current_room_resource = rooms.get(randi_range(0, rooms.size() - 1))
	var room: Room = current_room_resource.scene.instantiate()
	room.global_transform = current_exit.global_transform
	room_collection.add_child(room)
	room.force_update_transform()
	if not can_place_room(room):
		room.free()
		spawn_room()
		return
	room_amount -= 1
	exits.erase(current_exit)
	exits.append_array(room.get_exits())
	timer.start()
	spawn_room()


func can_place_room(room: Room) -> bool:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var collision_result: Array[Dictionary]
	for child: Node in room.overlap.get_children():
		if child is not CollisionShape3D:
			continue
		var shape: CollisionShape3D = child
		var parameters: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
		parameters.shape = shape.shape
		parameters.transform = shape.global_transform
		parameters.collide_with_areas = true
		parameters.collide_with_bodies = false
		parameters.collision_mask = 512 # Room collision layer
		parameters.exclude = [room.overlap.get_rid()]
		collision_result.append_array(space_state.intersect_shape(parameters, 1))
		if collision_result.size() > 0:
			return false
	return true


func place_dead_ends() -> void:
	for exit: Arrow in exits:
		var random_dead_end: int = randi_range(0, dead_ends.size() - 1)
		var dead_end: Node3D = dead_ends[random_dead_end].instantiate()
		dead_end.transform = exit.global_transform
		add_child(dead_end)


func _set_up_timer() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = FAILSAFE_TIME
	timer.start()
	var _connection_error: int = timer.timeout.connect(delete_random_room)


func delete_random_room() -> void:
	var random_room: int = randi_range(0, room_collection.get_children().size() - 1)
	var room: Room = room_collection.get_children()[random_room]
	for exit: Arrow in room.exits.get_children():
		exits.erase(exit)
	room_amount -= 1
	room.queue_free()
