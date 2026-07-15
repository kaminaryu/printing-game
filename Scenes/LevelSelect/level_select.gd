extends Control

const LEVEL_FOLDER = "res://Resources/Levels/"

@onready var target_grid = $TargetGrid
@onready var level_label = $"Level Title"

func _load_level(level_data: LevelData) -> void:
	target_grid.update_preview(level_data)
	level_label.text = level_data.level_name
	
func _load_level_by_number(level_num: int) -> bool:
	var path: String = "res://Resources/Levels/%d.tres" % level_num
	
	if ResourceLoader.exists(path):
		var loaded_resource = load(path) as LevelData
		_load_level(loaded_resource)
	
	return true
	

func _ready() -> void:
	_load_level_by_number(GameMaster.current_level_num)
	_load_level_data()


func _on_forward_pressed() -> void:
	GameMaster.current_level_num = ((GameMaster.current_level_num) % 31) + 1
	_load_level_by_number(GameMaster.current_level_num)

	_load_level_data()


func _on_backward_pressed() -> void:
	GameMaster.current_level_num = ((GameMaster.current_level_num + 29) % 31) + 1
	_load_level_by_number(GameMaster.current_level_num)

	_load_level_data()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")



func _load_level_data() -> void :
	var level_data: Dictionary = GameMaster.load_level_data()
	if (level_data["level_completed"]) :
		$"Completed Level".text = "Completed"
	else :
		$"Completed Level".text = "Uncompleted"
		

	var time_elapsed_ms = level_data["time_elapsed"]

	if (time_elapsed_ms == -1) :
		$"Time Elapsed".text = "--:--.--"
	else :
		$"Time Elapsed".text = str(_format_time_ms(time_elapsed_ms))



func _format_time_ms(time: float) -> String:
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
