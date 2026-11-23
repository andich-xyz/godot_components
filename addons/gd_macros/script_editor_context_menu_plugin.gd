@tool
extends EditorContextMenuPlugin


const GD_MACROS_CREATE_FUNCTION_SHORTCUT = preload("uid://bixxbpkcdd4jl")
const GD_MACROS_CREATE_FUNCTION_ICON = preload("uid://btfv727ulw57v")


func _init() -> void:
	add_menu_shortcut(
		GD_MACROS_CREATE_FUNCTION_SHORTCUT,
		_on_create_function_pressed
	)


func _popup_menu(paths: PackedStringArray) -> void:
	add_context_menu_item_from_shortcut(
		"Create Function from Selection",
		GD_MACROS_CREATE_FUNCTION_SHORTCUT,
		GD_MACROS_CREATE_FUNCTION_ICON
	)


func _on_create_function_pressed(code_edit: CodeEdit) -> void:
	if not code_edit:
		return
	var selected_text: String = code_edit.get_selected_text().strip_edges()
	if selected_text.contains("\n"):
		selected_text = selected_text.get_slice("\n", 0)
	if selected_text.is_empty():
		selected_text = code_edit.get_word_under_caret()
		if selected_text.is_empty():
			return
	
	if is_variable_declaration(selected_text):
		var variable_name: StringName = get_variable_name(selected_text)
		var variable_type: StringName = get_variable_type(selected_text)
		if variable_name and variable_type:
			_process_variable_setter(code_edit, variable_name, variable_type)
			return
	
	if is_connection(selected_text):
		_process_connection(code_edit, selected_text)
		return
	
	selected_text = selected_text.replace(".", "_")
	selected_text = selected_text.to_snake_case()
	
	var new_function_template = "func %s() -> void:\n\tpass" % selected_text
	code_edit.deselect()
	
	insert_at_last_line(code_edit, new_function_template)


func is_variable_declaration(line: String) -> bool:
	if not line.contains("var"):
		return false
	return true


func is_connection(selected_text: String) -> bool:
	if selected_text.contains(".connect("):
		return true
	return false


func get_variable_name(line: String) -> StringName:
	var variable_name: StringName
	var line_components: PackedStringArray = line.split("var")
	line = line_components[1].strip_edges()
	if line.contains(":"):
		line_components = line.split(":")
		return line_components[0].strip_edges()
	
	if line.contains("="):
		line_components = line.split("=")
		return line_components[0].strip_edges()
	return line.strip_edges()


func get_variable_type(line: String) -> StringName:
	if not line.contains(":"):
		return &""
	if line.count(":") == 1 and line.strip_edges().ends_with(":"):
		return &""
	line = line.split(":")[1]
	if line.contains("="):
		line = line.split("=")[0].strip_edges()
	return line


func _process_variable_setter(code_edit: CodeEdit, name: StringName, type: StringName) -> void:
	var line_index: int = code_edit.get_caret_line() - 1
	var line: String = code_edit.get_line(line_index)
	var line_length: int = line.length()
	var insert_text: String = "\n\tset = set_%s" % [name]
	if line.ends_with(":"):
		code_edit.insert_text(insert_text, line_index, line_length)
	else:
		insert_text = ":" + insert_text
		code_edit.insert_text(insert_text, line_index, line_length)
	
	insert_text = "func set_{name}(_{name}: {type}) -> void:
	{name} = _{name}".format({
		"name": name,
		"type": type,
	})
	insert_at_last_line(code_edit, insert_text)


func _process_connection(code_edit: CodeEdit, selected_text: StringName) -> void:
	var components: PackedStringArray = selected_text.split(".connect(")
	var function_name: StringName
	if components[1] == ")":
		function_name = components[0].strip_edges()
		if function_name.contains(" "):
			function_name = function_name.get_slice(" ", -1)
		function_name = "_on_" + function_name.to_snake_case().replace(".", "_")
	else:
		if components[1].contains(","):
			function_name = components[1].get_slice(",", 0).strip_edges()
		else:
			function_name = components[1].strip_edges()
			if function_name.ends_with(")"):
				function_name = function_name.replace(")", "").strip_edges()
	
	var insert_text: String = "func %s() -> void:\n\tpass" % function_name
	insert_at_last_line(code_edit, insert_text)


func insert_at_last_line(code_edit: CodeEdit, text: String) -> void:
	var last_line = code_edit.get_line_count() - 1
	var last_line_length = code_edit.get_line(last_line).length()
	if code_edit.get_line(last_line).length() > 0:
		text = "\n" + text
	code_edit.insert_text("\n\n" + text, last_line, last_line_length)
