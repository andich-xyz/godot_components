@tool
extends TextureRect


signal animation_finished
@export var flipbook_size: Vector2i = Vector2i(8, 8)
@export var one_shot: bool = false
@export var playing: bool = false
var sprite_size: Vector2i
var U: int = 0
var V: int = 0
var iteration: int = 0
var frame: int = 0
var allow_playing: bool = false
var atlas_texture: AtlasTexture


func _ready() -> void:
	if texture == null or texture is not AtlasTexture:
		printerr("Not a valid texture set for " + name + " at " + get_path().get_concatenated_names())
		return
	atlas_texture = texture as AtlasTexture
	var flipbook_size_f: Vector2 = Vector2(flipbook_size)
	sprite_size = atlas_texture.atlas.get_size() / flipbook_size_f
	reset_texture_rect(true)


func _process(_delta: float) -> void:
	reset_texture_rect()
	if Engine.is_editor_hint() and playing:
		step()
	else:
		reset_texture_rect(true)
	if not allow_playing:
		return
	step()


func reset_texture_rect(reset_position: bool = false) -> void:
	if reset_position:
		atlas_texture.region = Rect2(0.0, 0.0, sprite_size.x, sprite_size.y)
		return
	if atlas_texture.region.size == Vector2(0.0, 0.0):
		atlas_texture.region = Rect2(atlas_texture.region.position.x, atlas_texture.region.position.y, sprite_size.x, sprite_size.y)


func step() -> void:
	if frame % 2 == 0:
		frame += 1
		return
	atlas_texture.region = Rect2(Vector2(U, V) * Vector2(sprite_size), sprite_size)
	U = (U + 1) % flipbook_size.x
	frame += 1
	if U == 0:
		V = (V + 1) % flipbook_size.y
		if V == 0:
			iteration += 1
			animation_finished.emit()
	if iteration == 1 and one_shot and not Engine.is_editor_hint():
		queue_free()


func play_animation() -> void:
	allow_playing = true


func stop_animation() -> void:
	allow_playing = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
		playing = false
		reset_texture_rect(true)
