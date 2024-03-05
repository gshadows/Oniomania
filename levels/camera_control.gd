extends Node3D

const FOLLOW_SPEED := 2.0

@onready var cam: Camera3D = $Camera3D
@export var player: Player = null


func setup() -> void:
	cam.current = true


func _process(delta):
	if not player: return
	var dir := player.global_position - cam.global_position
	dir.y = 0
	dir.z += 2.0
	cam.global_position += dir * (FOLLOW_SPEED * delta)
