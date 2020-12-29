tool
class_name VoxelMesh, "res://addons/Voxel-Core/assets/classes/VoxelMesh.png"
extends "res://addons/Voxel-Core/classes/VoxelObject.gd"
# The most basic voxel visualization object, for a moderate amount of voxels.



## Private Variables
# Used voxels, Dictionary<Vector3, int>
var _voxels := {}



## Built-In Virtual Methods
func _get(property : String):
	if property == "VOXELS":
		return _voxels


func _set(property : String, value):
	if property == "VOXELS":
		_voxels = value
		return true
	return false


func _get_property_list():
	var properties = []
	
	properties.append({
		"name": "VOXELS",
		"type": TYPE_DICTIONARY,
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_STORAGE,
	})
	
	return properties



## Public Methods
func empty() -> bool:
	return _voxels.empty()


func set_voxel(grid : Vector3, voxel : int) -> void:
	_voxels[grid] = voxel


func set_voxels(voxels : Dictionary) -> void:
	erase_voxels()
	_voxels = voxels


func get_voxel_id(grid : Vector3) -> int:
	return _voxels.get(grid, -1)


func get_voxels() -> Array:
	return _voxels.keys()


func erase_voxel(grid : Vector3) -> void:
	_voxels.erase(grid)


func erase_voxels() -> void:
	_voxels.clear()


func update_mesh() -> void:
	if not _voxels.empty():
		var vt := VoxelTool.new()
		# TODO Retain multiple materials
		var material = get_surface_material(0) if get_surface_material_count() > 0 else null
		
		match MeshModes.NAIVE if edit_hint else mesh_mode:
			MeshModes.GREEDY:
				mesh = greed_volume(_voxels.keys(), vt)
			_:
				mesh = naive_volume(_voxels.keys(), vt)
		
		if is_instance_valid(mesh):
			mesh.surface_set_name(0, "voxels")
			set_surface_material(0, material)
	else:
		mesh = null
	.update_mesh()


func update_static_body() -> void:
	var staticBody = get_node_or_null("StaticBody")
	
	if (edit_hint or static_body) and is_instance_valid(mesh):
		if not is_instance_valid(staticBody):
			staticBody = StaticBody.new()
			staticBody.set_name("StaticBody")
			add_child(staticBody)
		
		var collisionShape
		if staticBody.has_node("CollisionShape"):
			collisionShape = staticBody.get_node("CollisionShape")
		else:
			collisionShape = CollisionShape.new()
			collisionShape.set_name("CollisionShape")
			staticBody.add_child(collisionShape)
		collisionShape.shape = mesh.create_trimesh_shape()
		
		if static_body and not staticBody.owner:
			staticBody.set_owner(get_tree().get_edited_scene_root())
		elif not static_body and staticBody.owner:
			staticBody.set_owner(null)
		if static_body and not collisionShape.owner:
			collisionShape.set_owner(get_tree().get_edited_scene_root())
		elif not static_body and staticBody.owner:
			collisionShape.set_owner(null)
	elif is_instance_valid(staticBody):
		remove_child(staticBody)
		staticBody.queue_free()
