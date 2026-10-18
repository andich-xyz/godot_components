@tool @icon("res://assets/textures/icons/script_code.tres")
class_name StatsManager
extends Node
## Manages [Entity]'s stats by requesting to change actual values of corresponding nodes.
## The requests are made after finishing all the nesessary calculations.


signal damage_taken(damage: Damage, amount: float)
signal hurt_hard
#region Stat references
const ATTACK_DISTANCE: Stat = preload("stats/attack_distance.tres")
const ATTACK_SPEED: Stat = preload("stats/attack_speed.tres")
const DAMAGE: Stat = preload("stats/damage.tres")
const DEFENCE: Stat = preload("stats/defence.tres")
const HEALTH: Stat = preload("stats/health.tres")
const MANA: Stat = preload("stats/mana.tres")
const MAX_HEALTH: Stat = preload("stats/max_health.tres")
const MAX_MANA: Stat = preload("stats/max_mana.tres")
const MOVEMENT_SPEED: Stat = preload("stats/movement_speed.tres")
const TOUGHNESS: Stat = preload("stats/toughness.tres")
const STATS: Array[Stat] = [ATTACK_DISTANCE, ATTACK_SPEED, HEALTH, MAX_HEALTH, MANA, MAX_MANA, MOVEMENT_SPEED, TOUGHNESS]
#endregion
@export_tool_button("Fill empty StatDatas") var fill_empty_stat_datas: Callable = _fill_empty_stat_datas
@export var stat_datas: Dictionary[Stat, StatData]
@export var damage_data: DamageDefenceData
@export var defence_data: DamageDefenceData
var effect_datas: Array[EffectData]


func add_effect_data(effect_data: EffectData) -> void:
	effect_datas.append(effect_data)
	effect_data.expired.connect(effect_datas.erase.bind(effect_data), CONNECT_ONE_SHOT)


func remove_effect_data(effect_data: EffectData) -> void:
	effect_data.expired.emit()


func add_stat_modifier_data(stat_modifier_data: StatModifierData) -> void:
	var stat_data: StatData = get_stat_data(stat_modifier_data.stat)
	stat_data.add_stat_modifier_data(stat_modifier_data)


func remove_stat_modifier_data(stat_modifier_data: StatModifierData) -> void:
	var stat_data: StatData = get_stat_data(stat_modifier_data.stat)
	stat_data.remove_stat_modifier_data(stat_modifier_data)


func add_damage_defence_data_modifier(damage: Damage, stat_modifier_data: StatModifierData) -> void:
	if damage_data and stat_modifier_data.stat == DAMAGE:
		damage_data.stat_datas[damage].add_stat_modifier_data(stat_modifier_data)
	if defence_data and stat_modifier_data.stat == DEFENCE:
		defence_data.stat_datas[damage].add_stat_modifier_data(stat_modifier_data)


func remove_damage_defence_data_modifier(damage: Damage, stat_modifier_data: StatModifierData) -> void:
	if damage_data and stat_modifier_data.stat == DAMAGE:
		damage_data.stat_datas[damage].remove_stat_modifier_data(stat_modifier_data)
	if defence_data and stat_modifier_data.stat == DEFENCE:
		defence_data.stat_datas[damage].remove_stat_modifier_data(stat_modifier_data)


func take_damage(hit_box: HitBox) -> void:
	var hit_box_damage_data: DamageDefenceData = hit_box.damage_data
	var health_stat_data: StatData = get_stat_data(HEALTH)
	var max_health_stat_data: StatData = get_stat_data(MAX_HEALTH)
	if not health_stat_data:
		return
	if not hit_box_damage_data:
		return
	for damage: Damage in hit_box_damage_data.stat_datas:
		var defence_data_value: float
		if defence_data.stat_datas.has(damage):
			defence_data_value = defence_data.stat_datas[damage].value
		else:
			var new_stat_data: StatData = StatData.new()
			new_stat_data.value = 0.0
			defence_data.add_damage_stat_data(damage, new_stat_data)
			defence_data_value = 0.0
		var damage_sum: float = hit_box_damage_data.stat_datas[damage].value * \
			damage.defence_base / (defence_data_value + damage.defence_base)
		if damage_sum == 0.0:
			continue
		var old_health: float = health_stat_data.value
		health_stat_data.value -= clampf(damage_sum, 0, max_health_stat_data.value)
		var new_health: float = health_stat_data.value
		print_rich("[color=%s]%s[/color]: %s\t%s\t>\t%s" % [damage.accent_color.to_html(), damage.name, damage_sum, old_health, new_health])
		damage_taken.emit(damage, damage_sum)
		if damage_sum >= get_stat_data(TOUGHNESS).value:
			hurt_hard.emit()


func get_stat_data(stat: Stat) -> StatData:
	if not stat_datas.has(stat):
		return null
	return stat_datas[stat]


func get_stat_value(stat: Stat) -> float:
	if not get_stat_data(stat):
		return 0
	return get_stat_data(stat).value


#region fill empty stat datas
func _fill_empty_stat_datas() -> void:
	var editor_file_dialog: EditorFileDialog = EditorFileDialog.new()
	editor_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	editor_file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	if not editor_file_dialog.dir_selected.is_connected(_on_dir_selected):
		editor_file_dialog.dir_selected.connect(_on_dir_selected.bind(editor_file_dialog))
	EditorInterface.get_base_control().add_child(editor_file_dialog)
	editor_file_dialog.popup_centered_ratio(0.5)
	editor_file_dialog.visibility_changed.connect(_on_editor_file_dialog_visibility_changed, CONNECT_APPEND_SOURCE_OBJECT)


func _on_dir_selected(dir: String, editor_file_dialog: EditorFileDialog) -> void:
	for stat: Stat in STATS:
		if get_stat_data(stat):
			continue
		var stat_data: StatData = StatData.new()
		var path: String = "".join([
			dir,
			"/",
			owner.name.to_snake_case(),
			"_",
			stat.name.to_snake_case(),
			"_",
			"stat_data.tres"
		])
		ResourceSaver.save(stat_data, path)
		stat_data.resource_path = path
		stat_data.resource_local_to_scene = true
		stat_data.stat = stat
		stat_datas[stat] = stat_data
	editor_file_dialog.queue_free()


func _on_editor_file_dialog_visibility_changed(editor_file_dialog: EditorFileDialog) -> void:
	editor_file_dialog.queue_free()
#endregion
