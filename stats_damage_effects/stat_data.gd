@tool
class_name StatData
extends Resource


@export var stat: Stat
@export var value: float = 1.0:
	set = set_value,
	get = get_value
@export var stat_modifier_datas: Array[StatModifierData]: ## Not intended to be set directly. Use [method add_stat_modifier_data] or set the entire array as a variable.
	set = set_stat_modifier_datas
var _raw_value: float
var _calculated_value: float = -1.0
var connected_callables: Dictionary[StatModifierData, Callable]


func _init() -> void:
	_raw_value = _modify_value(value, true)
	changed.connect(_on_changed)


#region setters/getters
func set_value(_value: float) -> void:
	var previous_value: float = _raw_value
	var new_value: float = max(_value, 0.0)
	if new_value == previous_value:
		return
	value = new_value
	_raw_value = new_value
	emit_changed()


func get_value() -> float:
	if Engine.is_editor_hint():
		return value
	if stat_modifier_datas.is_empty() and not Engine.is_editor_hint():
		return value
	if _calculated_value < 0:
		_calculated_value = _modify_value(_raw_value)
	return _calculated_value
#endregion


func _modify_value(_value: float, revert: bool = false) -> float:
	var final_value: float = _value
	var power: float = 0.0
	var multiplier: float = 0.0
	var addition: float = 0.0
	for stat_modifier_data: StatModifierData in stat_modifier_datas:
		power += stat_modifier_data.power
		multiplier += stat_modifier_data.multiplier
		addition += stat_modifier_data.addition
	if revert:
		final_value = ((final_value - addition) / (1.0 + multiplier / 100.0)) - power
	else:
		final_value = (final_value + power) * (1 + multiplier / 100) + addition
	return final_value


func add_stat_modifier_data(stat_modifier_data: StatModifierData) -> void:
	stat_modifier_datas.append(stat_modifier_data)
	stat_modifier_data.expired.connect(remove_stat_modifier_data.bind(stat_modifier_data), CONNECT_ONE_SHOT)
	var setter_callable: Callable = set.bind("_calculated_value", -1.0)
	stat_modifier_data.changed.connect(setter_callable)
	connected_callables[stat_modifier_data] = setter_callable
	emit_changed()


func remove_stat_modifier_data(stat_modifier_data: StatModifierData) -> void:
	var old_value: float = value
	stat_modifier_datas.erase(stat_modifier_data)
	stat_modifier_data.changed.disconnect(connected_callables[stat_modifier_data])
	connected_callables.erase(stat_modifier_data)
	if stat_modifier_data.apply_on_expired:
		value = old_value
	emit_changed()


func set_stat_modifier_datas(_stat_modifier_datas: Array[StatModifierData]) -> void:
	stat_modifier_datas = _stat_modifier_datas
	emit_changed()


func clear_stat_modifier_datas() -> void:
	stat_modifier_datas.clear()
	emit_changed()


func _on_changed() -> void:
	_calculated_value = -1.0


func _get_custom_preview_texture() -> Texture2D:
	if not stat:
		return null
	return stat.icon
