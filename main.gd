extends Node

@onready var menu := $MenuNormal
var level: GameManager = null

func _ready() -> void:
	if OS.is_debug_build() and (DisplayServer.get_screen_count() > 1):
		DisplayServer.window_set_current_screen(DisplayServer.get_screen_count() - 1)
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

func _on_menu_normal_quit() -> void:
	get_tree().quit()

func _unhandled_input(event:InputEvent) -> void:
	if level and event.is_action_pressed("pause"):
		if get_tree().paused:
			unpause()
		else:
			pause()
		get_viewport().set_input_as_handled()

func pause() -> void:
	get_tree().paused = true
	if level: level.visible = false
	menu.visible = true

func unpause() -> void:
	menu.visible = false
	if level: level.visible = true
	get_tree().paused = false

func _on_menu_normal_play() -> void:
	menu.visible = false
	if level:
		level.visible = true
	else:
		_load_game()
	get_tree().paused = false

func _load_game() -> void:
	level = preload("res://levels/level_01.tscn").instantiate()
	add_child(level)
	level.setup()
	level.win.connect(_on_level_win)
	level.loose.connect(_on_level_loose)

func _end_game() -> void:
	level.queue_free()
	remove_child(level)

func _on_level_win() -> void:
	pause()
	_end_game()

func _on_level_loose() -> void:
	pause()
	_end_game()
