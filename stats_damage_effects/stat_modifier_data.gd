class_name StatModifierData
extends Resource


signal expired
@export var stat: Stat
@export var power: float = 0.0: ## Addition to the base [StatData.value] before [param multiplier] and [param addition].
	set = set_power
@export_custom(PROPERTY_HINT_NONE, "suffix: %") var multiplier: float = 0.0: ## Multiplies [StatData.value] after the addition of [param power], but before the addition of [param addition].
	set = set_multiplier
@export var addition: float = 0.0: ## Addition to the [StatData.value] after [param power] and [param multiplier] modifications.
	set = set_addition
@export var apply_on_expired: bool = false ## Will add the [param addition] value to the  [StatData].[param value] on [signal exired] signal.


func set_power(_power: float) -> void:
	power = _power
	emit_changed()


func set_multiplier(_multiplier: float) -> void:
	multiplier = _multiplier
	emit_changed()


func set_addition(_addition: float) -> void:
	addition = _addition
	emit_changed()
