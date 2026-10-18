@tool
class_name Move
extends Resource


@export var name: StringName = &""
@export var animation: Animation
@export var hit_type: HitBox.HitBoxType = HitBox.HitBoxType.ONE_SHOT
@export var damage_values: Dictionary[Damage, float]
@export var effect_datas: Array[EffectData]
var animation_name: StringName:
	get = get_animation_name


func get_animation_name() -> StringName:
	if animation:
		return animation.resource_path.get_file().split(".")[0]
	return ""
