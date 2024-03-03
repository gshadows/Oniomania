extends Node3D

const FOLLOW_SPEED := 1.0

@onready var cam: Camera3D = $Camera3D
var player: Player = null


func setup(_player:Player) -> void:
	player = _player


func _process(delta):
	if not player: return
	var dir := player.global_position - global_position
	global_position += dir * (FOLLOW_SPEED * delta)
