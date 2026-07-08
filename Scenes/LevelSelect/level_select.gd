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


func _on_forward_pressed() -> void:
	GameMaster.current_level_num = ((GameMaster.current_level_num) % 30) + 1
	_load_level_by_number(GameMaster.current_level_num)

func _on_backward_pressed() -> void:
	GameMaster.current_level_num = ((GameMaster.current_level_num + 28) % 30) + 1
	_load_level_by_number(GameMaster.current_level_num)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
