extends TextureRect

signal play
signal quit

@onready var AUDIO_BUS_MASTER = AudioServer.get_bus_index("Master")

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
	play.emit()

func _on_button_quit_pressed():
	quit.emit()

func _on_button_info_pressed():
	%Menu.visible = false
	%Info.visible = true

func _on_button_thanks_pressed():
	%Menu.visible = true
	%Info.visible = false