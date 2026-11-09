extends Node


@export var cell_size: float = 32


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var mouse_button_event: InputEventMouseButton = event
		printt(mouse_button_event.position, position_to_addres(mouse_button_event.position))
	
	var vector: Vector2 =Input.get_vector(
		&"ui_left",
		&"ui_right",
		&"ui_up",
		&"ui_down"
	)
	
	if event.is_pressed():
		print(vector)

func position_to_addres(position: Vector2) -> Vector2i:
	return Vector2i(position / cell_size)
