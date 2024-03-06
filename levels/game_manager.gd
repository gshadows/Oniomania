class_name GameManager extends Node3D

const END_GAME_DELAY_SEC := 2.0

signal win
signal loose
signal before_end_game(is_win: bool)
signal new_level(level: int)

@export_range(0.1, 20.0, 0.1) var difficulty_modifier := 1.0
@export var difficulty_after     := [   5,   7,  10,  12,  16,  20,  25,   30,  35 ]
@export var difficulty_modifiers := [ 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 7.0, 10.0,   0 ]

@onready var garbage_manager := $Garbage
@onready var camera_control := $CameraControl
@onready var wife: Wife = $Wife
@onready var player: Player = $Player
#@onready var neighboar: Neighboar = $Neighboar

var garbage_cars := 0
var garbage_collected := 0


func setup() -> void:
	camera_control.setup()


func set_difficulty_modifier(modifier: float) -> void:
	difficulty_modifier = modifier
	wife.difficulty_modifier = modifier
	player.difficulty_modifier = modifier
	garbage_manager.difficulty_modifier = modifier


func _on_garbage_garbage_overflow():
	set_difficulty_modifier(0)
	_end_game(false)


func _on_player_throw_garbage():
	# Increase counter.
	garbage_collected += 1
	# Increase difficulty after certain number of collected trash.
	for i:int in range(difficulty_after.size()):
		var required: int = difficulty_after[i]
		if garbage_collected < required:
			break
		if garbage_collected == required:
			set_difficulty_modifier(difficulty_modifiers[i])
			if difficulty_modifier <= 0:
				_end_game(true)
			else:
				Audio.level_up()
				new_level.emit(i + 2)


func _end_game(is_win: bool) -> void:
	Audio.stop_music()
	if is_win:
		Audio.win()
	else:
		Audio.loose()
	before_end_game.emit(is_win)
	get_tree().create_timer(END_GAME_DELAY_SEC)
	if is_win:
		win.emit()
	else:
		loose.emit()
