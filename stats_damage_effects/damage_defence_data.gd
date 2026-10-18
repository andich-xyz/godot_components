@tool
class_name DamageDefenceData
extends Resource


enum StatKind {
	DAMAGE,
	DEFENCE,
}
const LIGHTNING: Damage = preload("damage/lightning.tres")
const PHYSICAL: Damage = preload("damage/physical.tres")
const ACID: Damage = preload("damage/acid.tres")
const FLAME: Damage = preload("damage/flame.tres")
const DAMAGES: Array[Damage] = [LIGHTNING, PHYSICAL, ACID, FLAME]
@export var stat_kind: StatKind:
	set = set_stat_kind
@export var stat_datas: Dictionary[Damage, StatData]: ## Not intended to be set directly outside Editor. Use [method add_stat_modifier_data] or set the entire array as a variable.
	set = set_stat_datas


func _init() -> void:
	resource_local_to_scene = true
	for damage: Damage in DAMAGES:
		if stat_datas.has(damage):
			continue
		var stat_data: StatData = StatData.new()
		stat_data.value = 0.0
		if stat_kind == StatKind.DAMAGE:
			stat_data.stat = StatsManager.DAMAGE
		elif stat_kind == StatKind.DEFENCE:
			stat_data.stat = StatsManager.DEFENCE
		stat_datas[damage] = stat_data


func set_stat_datas(_stat_datas: Dictionary[Damage, StatData]) -> void:
	stat_datas = _stat_datas
	emit_changed()


func add_damage_stat_data(damage: Damage, stat_data: StatData) -> void:
	stat_datas[damage] = stat_data
	emit_changed()


func set_move_damage_values(move: Move) -> void:
	for damage: Damage in stat_datas:
		if not move.damage_values.has(damage):
			stat_datas[damage].value = 0.0
	for damage: Damage in move.damage_values:
		if not stat_datas.has(damage):
			stat_datas[damage] = StatData.new()
			if stat_kind == StatKind.DAMAGE:
				stat_datas[damage].stat = StatsManager.DAMAGE
			elif stat_kind == StatKind.DEFENCE:
				stat_datas[damage].stat = StatsManager.DEFENCE
		stat_datas[damage].value = move.damage_values[damage]


func remove_damage_value(damage: Damage) -> void:
	if not stat_datas.has(damage):
		return
	stat_datas.erase(damage)
	emit_changed()


func set_stat_kind(_stat_kind: StatKind) -> void:
	stat_kind = _stat_kind
	for damage: Damage in stat_datas:
		if stat_kind == StatKind.DAMAGE:
			stat_datas[damage].stat = StatsManager.DAMAGE
		elif stat_kind == StatKind.DEFENCE:
			stat_datas[damage].stat = StatsManager.DEFENCE


func reset_damage_values() -> void:
	for damage: Damage in stat_datas:
		stat_datas[damage].value = 0.0
