extends PanelContainer

@export var preview_grid: Control
@export var level_num_label: Label
@export var level_name_label: Label
@export var ink_used_values: Label

@onready var LEVEL_EDITOR_SCENE: PackedScene = preload("res://Scenes/LevelEditor/level_editor.tscn")

var _level_num: int = 1


func generate_card(level_num: int) -> void :
	var level_data: LevelData = GameMaster.fetch_level_data(level_num)

	_level_num = level_num

	if level_data :
		preview_grid.generate_preview(level_num)

		level_num_label.text = "(%d)" % level_num
		level_name_label.text = level_data.level_name

		ink_used_values.text = "%d, %d, %d, %d" % level_data.amount_of_ink_used_cmyk


func _on_input_detector_button_up() -> void:
	print("Changing Scene to Level Editor")
	var level_editor: Control = LEVEL_EDITOR_SCENE.instantiate()

	level_editor.level_num = _level_num
	get_tree().change_scene_to_node(level_editor)
