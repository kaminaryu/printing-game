extends Control

const LEVEL_FOLDER = "res://Resources/Levels/"

@export var target_grid: Control
@export var level_label: Label


func _ready() -> void:
	target_grid.generate_preview(GameMaster.current_level_num)
	print("A total of ", GameMaster.level_count, " levels are loaded")
	_load_level_completion_data()


func _on_forward_pressed() -> void:
	GameMaster.current_level_num += 1
	#                                             1-based indexing
	GameMaster.current_level_num = posmod((GameMaster.current_level_num - 1), GameMaster.level_count) + 1

	target_grid.generate_preview(GameMaster.current_level_num)
	_load_level_completion_data()


func _on_backward_pressed() -> void:
	GameMaster.current_level_num += -1
	#                                             1-based indexing
	GameMaster.current_level_num = posmod((GameMaster.current_level_num - 1), GameMaster.level_count) + 1

	target_grid.generate_preview(GameMaster.current_level_num)
	_load_level_completion_data()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")



func _load_level_completion_data() -> void :
	var level_completion_file: Dictionary = GameMaster.load_level_completion_data()
	var time_elapsed_ms = level_completion_file["time_elapsed"]
	var level_data: LevelData = GameMaster.fetch_level_data(GameMaster.current_level_num)

	if (level_completion_file["level_completed"]) :
		$"Completed Level".text = "Completed"
	else :
		$"Completed Level".text = "Uncompleted"

	if (time_elapsed_ms == -1) :
		$"Time Elapsed".text = "--:--.--"
	else :
		$"Time Elapsed".text = str(_format_time_ms(time_elapsed_ms))

	level_label.text = level_data.level_name


func _format_time_ms(time: float) -> String:
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
