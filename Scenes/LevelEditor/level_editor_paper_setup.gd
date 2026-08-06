extends Control

const LEVEL_EDITOR_SCENE = preload("res://Scenes/LevelEditor/level_editor.tscn")

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
	var color_keys: Array[String] = []
	var lock_states: Array[bool] = []

	# get the grid colors and lock state
	for col in range(canvas_grid_size.x) :
		for row in range(canvas_grid_size.y) :
			var cell: GridCell = canvas_grid[col][row]

			color_keys.append(cell.color_key())
			lock_states.append(cell.is_ink_locked())


	# create a new LevelData and send it to level editor
	var level_data: LevelData = LevelData.new()
	var level_editor: Control = LEVEL_EDITOR_SCENE.instantiate()

	level_data.set_initial_grid(color_keys, lock_states)

	level_data.grid_size     = canvas_grid_size
	level_data.paper_color   = paper_editor.get_paper_color()

	level_data.target_colors = color_keys # for init history, basically the base grid
	level_data.lock_states   = lock_states

	# submit LevelData to level_editor
	level_editor.level_data = level_data
	get_tree().change_scene_to_node(level_editor)
