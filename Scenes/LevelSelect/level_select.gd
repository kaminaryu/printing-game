extends Control

const LEVEL_FOLDER = "res://Resources/Levels/"

@export var target_grid: Control
@export var level_label: Label


func _ready() -> void:
	target_grid.generate_preview(GameMaster.current_level_num)
	print("A total of ", GameMaster.level_count, " levels are loaded")
	_load_level_completion_data()
	_load_level_name()


func _on_forward_pressed() -> void:
	GameMaster.current_level_num += 1
	#                                             1-based indexing
	GameMaster.current_level_num = posmod((GameMaster.current_level_num - 1), GameMaster.level_count) + 1

	target_grid.generate_preview(GameMaster.current_level_num)
	_load_level_completion_data()
	_load_level_name()


func _on_backward_pressed() -> void:
	GameMaster.current_level_num += -1
	#                                             1-based indexing
	GameMaster.current_level_num = posmod((GameMaster.current_level_num - 1), GameMaster.level_count) + 1

	target_grid.generate_preview(GameMaster.current_level_num)
	_load_level_completion_data()
	_load_level_name()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _load_level_name() -> void :
	var level_data: LevelData = GameMaster.fetch_level_data(GameMaster.current_level_num)
	level_label.text = level_data.level_name


func _load_level_completion_data() -> void :
	var completion_data: Dictionary = GameMaster.load_level_completion_data()

	if (completion_data.is_empty()) :
		$"Time Elapsed".text = "--:--.--"
	else :
		$"Time Elapsed".text = str(_format_time_ms(completion_data["best_time"]))



func _format_time_ms(time_s: float) -> String:
	@warning_ignore("INTEGER_DIVISION")
	var minutes = int(time_s) / 60
	var seconds = int(time_s) % 60
	var milliseconds = int((time_s - int(time_s)) * 100) # get the decimals
	const one_hour_in_seconds = 3600

	if (time_s < one_hour_in_seconds) :
		return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

	@warning_ignore("INTEGER_DIVISION")
	var hours = minutes / 60
	minutes %= 60
	return "%d:%02d:%02d.%02d" % [hours, minutes, seconds, milliseconds]
