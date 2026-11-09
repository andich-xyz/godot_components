@tool
class_name TouchWASDControls
extends VBoxContainer


@export var button_size: int = 64:
	set = set_button_size
@export var texture_normal: Texture2D:
	set = set_texture_normal
@export var texture_pressed: Texture2D
var _buttons: Array[TouchScreenButton]


func _ready() -> void:
	for node: Node in get_tree().get_nodes_in_group(&"touch_wasd_buttons"):
		if node is not TouchScreenButton or not is_ancestor_of(node):
			continue
		var touch_screen_button: TouchScreenButton = node
		_buttons.append(touch_screen_button)
		
		touch_screen_button.texture_normal = texture_normal
		touch_screen_button.texture_pressed = texture_pressed
	
	button_size = button_size


func set_texture_normal(_texture_normal: Texture2D) -> void:
	texture_normal = _texture_normal
	for touch_screen_button: TouchScreenButton in _buttons:
		touch_screen_button.texture_normal = texture_normal


func set_texture_pressed(_texture_pressed: Texture2D) -> void:
	texture_pressed = _texture_pressed
	for touch_screen_button: TouchScreenButton in _buttons:
		touch_screen_button.texture_pressed = texture_pressed


func set_button_size(_button_size: int) -> void: 
	button_size = _button_size
	for touch_screen_button: TouchScreenButton in _buttons:
		var parent: Control = touch_screen_button.get_parent()
		parent.custom_minimum_size = Vector2(button_size, button_size)
