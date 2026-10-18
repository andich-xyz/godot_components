@tool
class_name FBXAsMesh
extends AssetsImport


var meshes: Array[Mesh]


func _handle_mesh_instance(mesh_instance_3d: MeshInstance3D, surface: int) -> void:
	mesh_instance_3d.mesh.surface_set_material(
		surface,
		load(
			_get_materials_folder_path()
			+ "/" + _get_file_name()
			+ ".material"
		) as Material
	)
	if not mesh_instance_3d.mesh in meshes:
		meshes.append(mesh_instance_3d.mesh)


func _post_iteration(_root_node: Node) -> void:
	_make_dir_at_source("meshes")
	for mesh: Mesh in meshes:
		ResourceSaver.save(mesh, get_source_file().get_base_dir()
		+ "/meshes/"
		+ _get_file_name()
		+ "_mesh_"
		+ str(meshes.find(mesh))
		+ ".res")
