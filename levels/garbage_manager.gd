class_name GarbageManager extends Node

signal garbage_overflow

@export var min_point: Marker3D
@export var max_point: Marker3D
@export_range(0.1, 3.0, 0.1) var offset_x: float = 1.0
@export_range(0.1, 3.0, 0.1) var offset_z: float = 1.0
@export var wife: Wife
@export var garbage_scene: PackedScene
@export var drop_count := 4

var slots: Array[Node3D] = []
var slot_x0 := 0.0
var slot_z0 := 0.0
var count_x: int
var count_z: int
var difficulty_modifier := 1.0 # Updated by the GameManager


func _ready() -> void:
	var max_gp := max_point.global_position
	var min_gp := min_point.global_position
	assert(max_gp.x > min_gp.x)
	assert(max_gp.z > min_gp.z)
	var cx = (max_gp.x - min_gp.x) / offset_x
	var cz = (max_gp.z - min_gp.z) / offset_z
	count_x = int(cx)
	count_z = int(cz)
	slot_x0 = (cx - count_x) / 2.0 + min_gp.x + offset_x / 2
	slot_z0 = (cz - count_z) / 2.0 + min_gp.z + offset_z / 2
	slots.resize(count_x * count_z)


func get_slot(x: int, z: int) -> Node3D:
	return slots[z * count_x + x]

func set_slot(x: int, z: int, trash: Node3D) -> void:
	slots[z * count_x + x] = trash

func point_to_slot_coords(pos: Vector3) -> Vector2i:
	var min_gp := min_point.global_position
	var x := int((pos.x - min_gp.x) / offset_x)
	var z := int((pos.z - min_gp.z) / offset_z)
	return Vector2i(x, z)

func slot_to_point_coords(slot_xz: Vector2i) -> Vector3:
	var min_gp := min_point.global_position
	return Vector3(slot_x0 + slot_xz.x * offset_x, min_gp.y, slot_z0 + slot_xz.y * offset_z)


func get_slot_center(x:int, z:int) -> Vector3:
	return Vector3(slot_x0 + x * offset_x, min_point.global_position.y, slot_z0 + z * offset_z)


func _on_wife_need_garbage_place() -> void:
	var slot_xz = _find_free_slot_sequentially()
	if slot_xz != null:
		wife.notify_garbage_slot(get_slot_center(slot_xz.x, slot_xz.y))
		return
	print_verbose("GARBAGE OVERFLOW")
	garbage_overflow.emit()


func _find_free_slot_sequentially():
	for x:int in range(count_x-1, -1, -1):
		for z:int in range(count_z):
			if get_slot(x, z) == null:
				return Vector2i(x, z)
	return null

func _find_free_slot_around(start_xz: Vector2i):
	@warning_ignore("integer_division")
	var cx := count_x / 2 + 1
	@warning_ignore("integer_division")
	var cz := count_z / 2 + 1
	for x:int in range(1, cx):
		for z:int in range(1, cz):
			var found_pos
			found_pos = _check_slot(start_xz, +x, -z); if found_pos != null: return found_pos
			found_pos = _check_slot(start_xz, +x,  0); if found_pos != null: return found_pos
			found_pos = _check_slot(start_xz, +x, +z); if found_pos != null: return found_pos
			found_pos = _check_slot(start_xz,  0, -z); if found_pos != null: return found_pos
			#found_pos= _check_slot(start_xz,  0,  0); if found_pos != null: return found_pos
			found_pos = _check_slot(start_xz,  0, +z); if found_pos != null: return found_pos
			found_pos = _check_slot(start_xz, -x, -z); if found_pos != null: return found_pos
			found_pos = _check_slot(start_xz, -x,  0); if found_pos != null: return found_pos
			found_pos = _check_slot(start_xz, -x, +z); if found_pos != null: return found_pos
	return null

func _check_slot(start_xz: Vector2i, x: int, z: int) -> Variant:
	x += start_xz.x
	z += start_xz.y
	if (x >= 0) and (x < count_x) and (z >= 0) and (z < count_z):
		if get_slot(x, z) == null:
			return Vector2i(x, z)
	return null


func _on_wife_drop_garbage(pos: Vector3) -> void:
	# Set first item at drop position.
	var slot_xz := point_to_slot_coords(pos)
	set_slot(slot_xz.x, slot_xz.y, _drop_trash(pos))
	# Add few more items based on difficulty.
	var count := drop_count + int(difficulty_modifier) - 2
	for i in range(count):
		var next_xz = _find_free_slot_around(slot_xz)
		if next_xz == null:
			return
		set_slot(next_xz.x, next_xz.y, _drop_trash(slot_to_point_coords(next_xz)))

func _drop_trash(pos: Vector3) -> Node3D:
	var trash := garbage_scene.instantiate() as Node3D
	trash.name = "Trash"
	trash.position = Vector3(pos.x + randf_range(-1, +1), pos.y, pos.z + randf_range(-1, +1))
	add_child(trash)
	return trash


func _on_player_take_garbage(garbage:Garbage) -> void:
	var slot_xz := point_to_slot_coords(garbage.global_position)
	set_slot(slot_xz.x, slot_xz.y, null)
	garbage.queue_free()
	remove_child(garbage)
