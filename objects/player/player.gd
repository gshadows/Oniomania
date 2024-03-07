class_name Player extends CharacterBody3D

signal throw_garbage
signal take_garbage(garbage:Garbage)

const WALK_SPEED := 4.0

@onready var raycast: RayCast3D = $RayCast3D
@onready var mesh_garbage: Node3D = $MeshGargabe

var difficulty_modifier := 1.0 # Updated by the GameManager
var holding_trash := false


func _process(_delta: float) -> void:
	_do_walk()
	_do_actions()

func _do_walk() -> void:
	var input := Input.get_vector("left", "right", "up", "down")
	var direction := Vector3(input.x, 0, input.y).normalized()
	if direction:
		look_at(global_position + direction)
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
	move_and_slide()


func _do_actions() -> void:
	if Input.is_action_just_pressed("action"):
		if raycast.is_colliding():
			var collider := raycast.get_collider()
			if collider is TrashCan:
				_drop_garbage()
			elif collider is Garbage:
				_take_garbage(collider)

func _drop_garbage() -> void:
	if not holding_trash: return
	holding_trash = false
	mesh_garbage.visible = false
	Audio.trash_can()
	throw_garbage.emit()

func _take_garbage(garbage:Garbage) -> void:
	if holding_trash: return
	holding_trash = true
	mesh_garbage.visible = true
	Audio.take()
	take_garbage.emit(garbage)
