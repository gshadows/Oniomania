extends Node

@export var _game_music: AudioStream
@export var _menu_music: AudioStream

@export var _sfx_win: AudioStream
@export var _sfx_loose: AudioStream
@export var _sfx_level_up: AudioStream
@export var _sfx_unpack: AudioStream
@export var _sfx_drop: AudioStream
@export var _sfx_take: AudioStream
@export var _sfx_trash_can: AudioStream
@export var _sfx_computer: AudioStream
@export var _sfx_door: AudioStream
@export var _shop_enter: AudioStream
@export var _shop_ok: AudioStream
@export var _put_goods: AudioStream
# DLC: Garbage Car
#@export var _sfx_call_utility: AudioStream
#@export var _sfx_car_stop: AudioStream
#@export var _sfx_car_engine: AudioStream
# DLC: Courier Delivery
#@export var _sfx_doorbell: AudioStream
#@export var _sfx_courier: AudioStream
# DLC: Neighboar
#@export var _sfx_chatting: AudioStream

@onready var _snd := $Sound
@onready var _mus := $Music
#@onready var _car := $Car


func _music(stream:AudioStream) -> void:
	_mus.stop()
	if stream == null: return
	_mus.stream = stream
	_mus.play()

func stop_music() -> void:
	_mus.stop()

func menu_music() -> void:
	_music(_menu_music)

func game_music() -> void:
	_music(_game_music)


func _sfx(stream:AudioStream) -> void:
	if stream == null: return
	await _snd.finished
	_snd.stream = stream
	_snd.play()

func win() -> void:			_sfx(_sfx_win)
func loose() -> void:		_sfx(_sfx_loose)
func level_up() -> void:	_sfx(_sfx_level_up)
func unpack() -> void:		_sfx(_sfx_unpack)
func drop() -> void:		_sfx(_sfx_drop)
func take() -> void:		_sfx(_sfx_take)
func trash_can() -> void:	_sfx(_sfx_trash_can)
func computer() -> void:	_sfx(_sfx_computer)
func door() -> void:		_sfx(_sfx_door)
func shop_enter() -> void:	_sfx(_shop_enter)
func shop_ok() -> void:		_sfx(_shop_ok)
func put_goods() -> void:	_sfx(_put_goods)

# DLC: Garbage Car
#func call_utility() -> void:
#	_sfx(_sfx_call_utility)
#func car_start() -> void:
#	if (_sfx_car != null) and not _car.playing:
#		_car.stream = _sfx_car_engine
#		_car.start()
#func car_stop() -> void:
#	_car.stop()
#	_sfx(_sfx_car_stop)

# DLC: Courier Delivery
#func doorbell() -> void:	_sfx(_sfx_doorbell)
#func courier() -> void:		_sfx(_sfx_courier)

# DLC: Neighboar
#func chatting() -> void:	_sfx(_sfx_chatting)
