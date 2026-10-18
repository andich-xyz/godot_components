@icon("res://assets/textures/icons/sword.tres")
class_name HitBox
extends Area3D


signal hit(hurt_box: Area3D)
enum HitBoxType {
	ONE_SHOT,
	CONTINUOUS,
	}
@export var hit_box_type: HitBoxType = HitBoxType.ONE_SHOT
@export var damage_data: DamageDefenceData
@export var effect_datas: Array[EffectData]
var move: Move:
	set = set_move


func set_move(_move: Move) -> void:
	move = _move
	if not move:
		return
	damage_data.set_move_damage_values(move)
	effect_datas = move.effect_datas


func reset_move() -> void:
	move = null
	damage_data.reset_damage_values()
	effect_datas = []
