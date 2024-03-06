extends Control

const BASED_ON_REAL_TIME_1_SEC := 2.0
const NEW_LEVEL_TIME_SEC := 1.0

@onready var based_real: Label = $BasedOnReal
@onready var level_label: Label = $Level

var score_value := 0


func _ready() -> void:
	await get_tree().create_timer(BASED_ON_REAL_TIME_1_SEC).timeout
	based_real.visible = false


func _on_player_throw_garbage() -> void:
	score_value += 1
	$Score.text = str(score_value)


func _on_level_01_new_level(level: int) -> void:
	level_label.text = tr("LEVEL_N") + str(level)
	level_label.visible = true
	await get_tree().create_timer(NEW_LEVEL_TIME_SEC).timeout
	level_label.visible = false


func _on_level_01_before_end_game(is_win: bool) -> void:
	if is_win:
		$Win.visible = true
	else:
		$Loose.visible = true
