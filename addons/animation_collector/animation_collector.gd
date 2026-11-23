@tool
class_name AnimationCollector
extends AnimationLibrary


@export_tool_button("Collect") var collect_animations: Callable = _collect_animations


func _collect_animations() -> void:
	for animation: String in get_animation_list():
		remove_animation(animation)
	var files: PackedStringArray = DirAccess.get_files_at(resource_path.get_base_dir())
	for file_path: String in files:
		var file: Variant = load(resource_path.get_base_dir() + "/" + file_path)
		if file is Animation:
			var animation: Animation = file
			add_animation(
				animation.resource_path.get_file().get_basename(),
				animation
			)
