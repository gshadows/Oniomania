extends Control

signal play
signal quit

@onready var AUDIO_BUS_MASTER = AudioServer.get_bus_index("Master")
@onready var timer: Timer = %Timer

var skip_dialog := false

func _ready() -> void:
	if TranslationServer.get_locale().to_lower().begins_with("ru"):
		%ButtonRU.button_pressed = true
	else:
		%ButtonEN.button_pressed = true
	print(AudioServer.get_bus_volume_db(AUDIO_BUS_MASTER))
	%SfxVolume.value = db_to_linear(AudioServer.get_bus_volume_db(AUDIO_BUS_MASTER))


func _on_button_en_toggled(toggled_on:bool) -> void:
	if toggled_on:
		TranslationServer.set_locale("en")
		%ButtonRU.button_pressed = false

func _on_button_ru_toggled(toggled_on:bool) -> void:
	if toggled_on:
		TranslationServer.set_locale("ru")
		%ButtonEN.button_pressed = false


func _on_sfx_volume_drag_ended(value_changed):
	AudioServer.set_bus_volume_db(AUDIO_BUS_MASTER, linear_to_db(value_changed))


func _on_button_start_pressed():
	await game_intro()
	play.emit()

func _on_button_quit_pressed():
	quit.emit()

func _on_button_info_pressed():
	%Menu.visible = false
	%Info.visible = true

func _on_button_thanks_pressed():
	%Menu.visible = true
	%Info.visible = false


func delay(time: float) -> bool:
	while not skip_dialog and (time > 0):
		timer.start()
		await timer.timeout
		time -= timer.wait_time
	return skip_dialog

func _phone_on() -> void:
	%MainMenu.visible = false
	%PhoneOFF.visible = true
	if await delay(1): return
	%PhoneOFF.visible = false
	%PhoneON.visible = true
	if await delay(0.5): return

func _phone_off() -> void:
	%PhoneON.visible = false
	%PhoneOFF.visible = true
	if await delay(0.5): return
	%MainMenu.visible = true
	%PhoneOFF.visible = false
	%StartDialog.visible = false
	%WinDialog.visible = false
	%LooseDialog.visible = false

func _play_dialog(root: Control) -> void:
	root.get_node("PhoneMsg1").visible = false
	root.get_node("PhoneMsg2").visible = false
	root.get_node("PhoneMsg3").visible = false
	root.get_node("PhoneMsg4").visible = false
	root.visible = true
	root.get_node("PhoneMsg1").visible = true
	Audio.new_message()
	if await delay(2): return
	root.get_node("PhoneMsg2").visible = true
	if await delay(2): return
	root.get_node("PhoneMsg3").visible = true
	Audio.new_message()
	if await delay(2): return
	root.get_node("PhoneMsg4").visible = true
	if await delay(5): return

func game_intro() -> void:
	Audio.stop_music()
	skip_dialog = false
	await _phone_on()
	if skip_dialog: return
	await _play_dialog(%StartDialog)
	if skip_dialog: return
	%StartDialog.visible = false
	await _phone_off()

func game_win_outro() -> void:
	skip_dialog = false
	await _phone_on()
	if skip_dialog: return
	await _play_dialog(%WinDialog)
	if skip_dialog: return
	%WinDialog.visible = false
	await _phone_off()

func game_loose_outro() -> void:
	skip_dialog = false
	await _phone_on()
	if skip_dialog: return
	await _play_dialog(%LooseDialog)
	if skip_dialog: return
	%LooseDialog.visible = false
	await _phone_off()


func _on_button_skip_pressed():
	skip_dialog = true
	%PhoneON.visible = false
	%PhoneOFF.visible = false
	%MainMenu.visible = true
	%StartDialog.visible = false
	%WinDialog.visible = false
	%LooseDialog.visible = false
