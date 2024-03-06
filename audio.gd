extends Node

@export var _game_music: AudioStream
@export var _menu_music: AudioStream

@export var _sfx_win: AudioStream
@export var _sfx_loose: AudioStream

@onready var _snd := $Sound
@onready var _mus := $Music


func _music(stream:AudioStream) -> void:
	_mus.stop()
	_mus.stream = stream
	_mus.play()

func menu_music() -> void:
	_music(_menu_music)

func game_music() -> void:
	_music(_game_music)

func stop_music() -> void:
	_mus.stop()


func _sfx(stream:AudioStream) -> void:
	_snd.stop()
	_snd.stream = stream
	_snd.play()

func win() -> void:
	_sfx(_sfx_win)

func loose() -> void:
	_sfx(_sfx_loose)
