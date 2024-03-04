class_name Player extends CharacterBody3D

const WALK_SPEED := 2.0

@export var garbage_manager: GarbageManager

var difficulty_modifier := 1.0 # Updated by the GameManager


func _ready():
	pass


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
		pass
