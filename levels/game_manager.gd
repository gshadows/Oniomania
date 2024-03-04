class_name GameManager extends Node3D

signal win
signal loose

@export var wife: Wife
@export var player: Player
#@export var neighboar: Neighboar
@export var garbage_manager: GarbageManager
@export_range(0.1, 20.0, 0.1) var difficulty_modifier := 1.0
@export var difficulty_after := [ 5, 10, 15, 20, 25, 30, 40, 50 ]

var garbage_cars := 0
var garbage_collected := 0


func _ready() -> void:
	if OS.is_debug_build() and (DisplayServer.get_screen_count() > 1):
		#DisplayServer.window_set_current_screen(DisplayServer.window_get_current_screen() ^ 1)
		DisplayServer.window_set_current_screen(DisplayServer.get_screen_count() - 1)
		#DisplayServer.window_set_current_screen(1)
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func set_difficulty_modifier(modifier: float) -> void:
	difficulty_modifier = modifier
	wife.difficulty_modifier = modifier
	player.difficulty_modifier = modifier
	garbage_manager.difficulty_modifier = modifier


func _on_garbage_garbage_overflow():
	pass # Replace with function body.


func _on_player_throw_garbage():
	# Increase counter.
	garbage_collected += 1
	# Increase difficulty after certain number of collected trash.
	for a in difficulty_after:
		if garbage_collected < a:
			break
		if garbage_collected == a:
			set_difficulty_modifier(difficulty_modifier + 0.1)
	
