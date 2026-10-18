@tool
class_name AssetsImport
extends EditorScenePostImport


const MATERIALS_PATH: String = "res://assets/materials"
const ENEMIES_PATH: String = "res://scenes/enemies/"
const PLAYER_PATH: String = "res://scenes/player/assets/aren.gltf"
const enemy_file_names: Array[StringName] = [
	"goblin_base",
	"eyeball",
	"pebbly",
]


func _post_import(root_node: Node) -> Node:
	_iterate(root_node)
	_post_iteration(root_node)
	return root_node


func _is_enemy(root_node: Node) -> bool:
	return get_source_file().begins_with(ENEMIES_PATH) \
		and enemy_file_names.has(get_source_file().get_file().get_basename()) \
		and get_source_file().get_extension() == "gltf" \
		and root_node is Node3D


func _is_player() -> bool:
	return get_source_file() == PLAYER_PATH


func replace_root_to_for_node(root_node: Node, node: Node) -> Node:
	root_node.add_sibling(node)
	node.name = root_node.name
	root_node.replace_by(node, true)
	root_node.free()
	root_node = node
	return root_node


func _iterate(root_node: Node) -> void:
	if root_node == null:
		return
	for child: Node in root_node.get_children():
		if child is MeshInstance3D:
			var mesh_instance_3d: MeshInstance3D = child
			for surface: int in mesh_instance_3d.mesh.get_surface_count():
				_handle_mesh_instance(mesh_instance_3d, surface)
		if child is AnimationPlayer:
			var animation_player: AnimationPlayer = child
			_handle_animation_player(animation_player)
		_continue_node_iteration(root_node, child)
		_iterate(child)


func _handle_mesh_instance(mesh_instance_3d: MeshInstance3D, surface: int) -> void:
	var material_name: StringName = mesh_instance_3d.mesh.surface_get_material(surface).to_string()
	if material_name.begins_with("(res"):
		material_name = material_name.split("):")[0]
		material_name = material_name.right(len(material_name) - 1).get_basename().split("/")[-1]
	else:
		material_name = material_name.split(" ()")[0]
	var dir_access: DirAccess = DirAccess.open(_get_materials_folder_path())
	if _is_player():
		dir_access.change_dir("materials")
	if dir_access.file_exists(material_name + ".material"):
		_set_material_on_surface(dir_access.get_current_dir() + "/" + material_name + ".material", surface, mesh_instance_3d.mesh)
		return
	elif dir_access.file_exists(material_name + ".tres"):
		_set_material_on_surface(dir_access.get_current_dir() + "/" + material_name + ".tres", surface, mesh_instance_3d.mesh)
		return
	dir_access.change_dir(MATERIALS_PATH)
	if dir_access.dir_exists(material_name):
		_set_material_on_surface(MATERIALS_PATH + "/" + material_name + "/" + material_name + ".material", surface, mesh_instance_3d.mesh)
		return
	printerr("No material for " + material_name + " at " + get_source_file())


func _handle_animation_player(animation_player: AnimationPlayer) -> void:
	for animation_name: String in animation_player.get_animation_list():
		var animation: Animation = animation_player.get_animation(animation_name)
		if animation_name.left(1) == animation_name.left(1).to_upper():
			var animation_library_name: StringName = animation_player.find_animation_library(animation)
			var animation_library: AnimationLibrary = animation_player.get_animation_library(animation_library_name)
			animation_library.remove_animation(animation_name)
			continue
		if is_loop_animation(animation_name):
			animation.loop_mode = Animation.LOOP_LINEAR
		_save_animation(animation, animation_name)


func _save_animation(animation: Animation, animation_name: String) -> void:
	_make_dir_at_source("animations")
	var save_path: String = get_source_file().get_base_dir() \
		+ "/animations/" \
		+ animation_name \
		+ ".res"
	ResourceSaver.save(animation, save_path)


func _set_material_on_surface(material_path: String, surface: int, mesh: Mesh) -> void:
	var material: Material = load(material_path)
	mesh.surface_set_material(surface, material)


func _get_materials_folder_path() -> String:
	return get_source_file().get_base_dir()


func _get_file_name() -> String:
	return get_source_file().get_file().get_slice(".", 0)


func is_loop_animation(animation: String) -> bool:
	return animation.contains("_loop")


func _continue_node_iteration(_root_node: Node, _node: Node) -> void:
	pass


func _post_iteration(_root_node: Node) -> void:
	pass


func _make_dir_at_source(folder_name: String) -> void:
	var dir_access: DirAccess = DirAccess.open(get_source_file().get_base_dir())
	if not dir_access.dir_exists(folder_name):
		dir_access.make_dir(folder_name)
