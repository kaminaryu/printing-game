extends Control

const LEVEL_EDITOR_SCRIPT = preload("res://Scenes/LevelEditor/level_editor.gd")

var canvas_grid_size := Vector2i(5, 5)

@export var paper_editor: Node2D

func _ready() -> void :
	paper_editor.draw_grid(canvas_grid_size)


func _on_width_input_value_changed(value: float) -> void:
	canvas_grid_size.x = int(value)
	paper_editor.draw_grid(canvas_grid_size)


func _on_height_input_value_changed(value: float) -> void:
	canvas_grid_size.y = int(value)
	paper_editor.draw_grid(canvas_grid_size)


func _on_paper_color_option_item_selected(index: int) -> void:
	var color_key: String = "670067"

	match index :
		0: color_key = "000"
		1: color_key = "100"
		2: color_key = "010"
		3: color_key = "001"

	paper_editor.change_paper_color(color_key)


func _on_apply_button_up() -> void:
	var canvas_grid: Array[Array] = paper_editor.canvas_grid
	var color_keys: Array[Array] = []
	var lock_states: Array[Array] = []

	# get the grid colors and lock state
	for col in range(canvas_grid_size.x) :
		var color_keys_column: Array = []
		var lock_states_column: Array = []

		for row in range(canvas_grid_size.y) :
			var cell: GridCell = canvas_grid[col][row]

			color_keys_column.append(cell.color_key())
			lock_states_column.append(cell.is_ink_locked())

		color_keys.append(color_keys_column)
		lock_states.append(lock_states_column)


	LevelEditorManager.level_name = "Lorem Ipsum"
	LevelEditorManager.grid_size = canvas_grid_size
	LevelEditorManager.color_keys = color_keys
	LevelEditorManager.lock_states = lock_states
	LevelEditorManager.level_num = 0
	LevelEditorManager.amount_of_ink_used_cmyk = [0, 0, 0, 0]
	LevelEditorManager.ink_limits = {"c": -1, "m": -1, "y": -1, "k": -1}
	LevelEditorManager.available_channels = ["c", "m", "y", "k"]

	get_tree().change_scene_to_file("res://Scenes/LevelEditor/level_editor.tscn")
