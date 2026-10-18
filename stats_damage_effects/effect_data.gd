@tool
class_name EffectData
extends Resource


signal expired
enum Execution {
	AT_START,
	PROCESS,
	AT_END,
}
enum Expiration {
	ON_AREA_EXIT,
	ON_TIMER_TIMEOUT,
	INSTANT,
	NEVER,
	CUSTOM,
}
@export var stat_modifier_data: StatModifierData
@export var execution: Execution
@export var expiration: Expiration:
	set(value):
		expiration = value
		notify_property_list_changed()
@export var ailment: Ailment
@export_custom(PROPERTY_HINT_NONE, "suffix: s") var duration: float = 1.0


func _init() -> void:
	resource_local_to_scene = true


func _validate_property(property: Dictionary) -> void:
	if property["name"] == &"duration":
		if not expiration == Expiration.ON_TIMER_TIMEOUT:
			property["usage"] = PROPERTY_USAGE_NO_EDITOR


func _on_hurt_box_area_exited(area: Area3D, hurt_box: Area3D, hit_box: HitBox) -> void:
	if area == hit_box:
		expired.emit()
		hurt_box.area_exited.disconnect(_on_hurt_box_area_exited.bind(hurt_box, hit_box))
