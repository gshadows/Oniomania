class_name GameManager extends Node3D

@export var wife: Wife
@export var player: Player
#@export var neighboar: Neighboar
@export var garbage_manager: GarbageManager


func _ready() -> void:
	if OS.is_debug_build() and (DisplayServer.get_screen_count() > 1):
		#DisplayServer.window_set_current_screen(DisplayServer.window_get_current_screen() ^ 1)
		DisplayServer.window_set_current_screen(DisplayServer.get_screen_count() - 1)
		#DisplayServer.window_set_current_screen(1)
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func set_difficulty_modifier(modifier: float) -> void:
	wife.difficulty_modifier = modifier
	player.difficulty_modifier = modifier
	garbage_manager.difficulty_modifier = modifier


func _on_garbage_garbage_overflow():
	pass # Replace with function body.
