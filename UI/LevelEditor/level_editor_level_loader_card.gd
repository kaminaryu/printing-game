extends PanelContainer

@export var preview_grid: Control
@export var level_num_label: Label
@export var level_name_label: Label
@export var ink_used_values: Label

const LEVEL_EDITOR_SCRIPT = preload("res://Scenes/LevelEditor/level_editor.gd")

var _level_num: int = 1


func generate_card(level_num: int) -> void :
	var level_data: LevelData = GameMaster.fetch_level_data(level_num)

	_level_num = level_num

	if level_data :
		preview_grid.generate_preview(level_num)

		level_num_label.text = "(%d)" % level_num
		level_name_label.text = level_data.level_name

		ink_used_values.text = "%s, %s, %s, %s" % [
			"INF" if level_data.ink_limits["c"] == -1 else str(level_data.ink_limits["c"]),
			"INF" if level_data.ink_limits["m"] == -1 else str(level_data.ink_limits["m"]),
			"INF" if level_data.ink_limits["y"] == -1 else str(level_data.ink_limits["y"]),
			"INF" if level_data.ink_limits["k"] == -1 else str(level_data.ink_limits["k"]),
		]


func _on_input_detector_button_up() -> void:
	var level_data: LevelData = GameMaster.fetch_level_data(_level_num)

	# set datas
	LevelEditorManager.level_name = level_data.level_name
	LevelEditorManager.grid_size = level_data.grid_size
	LevelEditorManager.color_keys = level_data.get_target_grid_2d()
	LevelEditorManager.lock_states = []
	LevelEditorManager.level_num = _level_num
	LevelEditorManager.amount_of_ink_used_cmyk = level_data.amount_of_ink_used_cmyk
	LevelEditorManager.ink_limits = level_data.ink_limits
	LevelEditorManager.available_channels = level_data.available_channels

	get_tree().change_scene_to_file("res://Scenes/LevelEditor/level_editor.tscn")
