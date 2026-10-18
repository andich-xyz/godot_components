@tool
class_name Damage
extends Resource


@export var name: StringName
@export var icon: Texture2D
@export var defence_base: float = 100 ## Determines the threshold for defence [Stat]. If the defence [Stat] value is equal to [param defence_base] then the final damage will be half of the original damage from  [HitBox].[param damage_defence_data]
@export var accent_color: Color
@export_multiline() var description: String

func _get_custom_preview_texture() -> Texture2D:
	return icon
