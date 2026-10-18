@tool
class_name InstanceOnBones
extends MultiMeshInstance3D


@export_tool_button("Spawn Crystals") var tool_spawn_crystals: Callable = spawn_crystals
@export var skeleton_3d: Skeleton3D
@export var minimum_bone_length: float = 0.05
@export var additional_scale: Vector3 = Vector3(2.0, 1.3, 2.0)
@export var big_bones_scale: Vector3 = Vector3(1.0, 1.0, 1.0)
@export var big_bones: Array[String]
@export var mesh: Mesh


func _ready() -> void:
	multimesh = null


func spawn_crystals() -> void:
	if not multimesh:
		multimesh = MultiMesh.new()
		multimesh.mesh = mesh
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
	var transforms: Dictionary[int, Transform3D]
	for bone: int in range(skeleton_3d.get_bone_count()):
		var point_transform: Transform3D
		point_transform = skeleton_3d.get_bone_global_pose(bone)
		var parent_transform: Transform3D = point_transform
		if not skeleton_3d.get_bone_parent(bone) == -1:
			parent_transform = skeleton_3d.get_bone_global_pose(skeleton_3d.get_bone_parent(bone))
		point_transform.basis = parent_transform.basis
		var bone_vector: Vector3 = parent_transform.origin - point_transform.origin
		var bone_length: float = bone_vector.length()
		if bone_length <= minimum_bone_length:
			continue
		point_transform.origin += bone_vector / 2
		point_transform = point_transform.scaled_local(Vector3(1.0, bone_length / 0.1, 1.0))
		if big_bones.has(skeleton_3d.get_bone_name(bone)):
			point_transform = point_transform.scaled_local(big_bones_scale)
		point_transform = point_transform.scaled_local(additional_scale)
		transforms[bone] = point_transform
	multimesh.instance_count = transforms.size()
	for point: int in range(multimesh.instance_count):
		var bone: int = transforms.keys()[point]
		multimesh.set_instance_transform(point, transforms[bone])
