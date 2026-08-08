extends Control

const LEVEL_EDITOR_SCENE = preload("res://Scenes/LevelEditor/level_editor.tscn")

var canvas_grid_size := Vector2i(5, 5)

@export var paper_editor: Node2D
@export var width_input_box: SpinBox
@export var height_input_box: SpinBox

func _ready() -> void :
	paper_editor.draw_grid(canvas_grid_size)
	PaperSetupHistoryManager.revert_grid_size.connect(_on_revert_grid_size)


func _on_width_input_value_changed(value: float) -> void:
	var data = {
		"grid_size": canvas_grid_size,
		"line_axis": PaperSetupHistoryManager.LineAxis.COL,
		"grid_line_cells_cmyk": [] as Array[String]
	}

	# save line info if the height decreases
	print(value, canvas_grid_size.x)
	if (value < canvas_grid_size.x) :
		print("nigger")
		data["grid_line_cells_cmyk"] = paper_editor.get_col_line_cells(canvas_grid_size.x - 1)

	# save current size as previous
	PaperSetupHistoryManager.record_action(
		PaperSetupHistoryManager.ActionType.RESIZE_CANVAS,
		data
	)

	var is_cloning_grid := true

	canvas_grid_size.x = int(value)
	paper_editor.draw_grid(canvas_grid_size, is_cloning_grid)



func _on_height_input_value_changed(value: float) -> void:
	var data = {
		"grid_size": canvas_grid_size,
		"line_axis": PaperSetupHistoryManager.LineAxis.ROW,
		"grid_line_cells_cmyk": [] as Array[String]
	}

	# save line info if the height decreases
	if (value < canvas_grid_size.y) :
		data["grid_line_cells_cmyk"] = paper_editor.get_row_line_cells(canvas_grid_size.y - 1)
		

	# save current size as previous
	PaperSetupHistoryManager.record_action(
		PaperSetupHistoryManager.ActionType.RESIZE_CANVAS,
		data
	)

	var is_cloning_grid := true

	canvas_grid_size.y = int(value)
	paper_editor.draw_grid(canvas_grid_size, is_cloning_grid)


func _on_paper_color_option_item_selected(index: int) -> void:
	var color_key: String = "670067"

	match index :
		0: color_key = "000"
		1: color_key = "100"
		2: color_key = "010"
		3: color_key = "001"

	paper_editor.change_paper_color(color_key)


func _on_undo_button_up() -> void:
	PaperSetupHistoryManager.undo_action(paper_editor.canvas_grid)


func _on_delete_button_up() -> void:
	pass


func _on_revert_grid_size(
	p_canvas_grid_size: Vector2i, 
	p_line_axis: PaperSetupHistoryManager.LineAxis,
	p_grid_line_cells_cmyk: Array[String]
) -> void :
	var is_cloning_grid := true
	paper_editor.draw_grid(p_canvas_grid_size, is_cloning_grid)
	canvas_grid_size = p_canvas_grid_size

	# block signal so that it doesnt trigger when we manually change the input boxes input
	width_input_box.set_block_signals(true)
	height_input_box.set_block_signals(true)

	width_input_box.value = p_canvas_grid_size.x
	height_input_box.value = p_canvas_grid_size.y

	width_input_box.set_block_signals(false)
	height_input_box.set_block_signals(false)

	# repainting back the deleted line of cells
	for i in range(p_grid_line_cells_cmyk.size()) :
		if (p_line_axis == PaperSetupHistoryManager.LineAxis.ROW) :
			paper_editor.paint_row(p_canvas_grid_size.y - 1, p_grid_line_cells_cmyk)
		else :
			paper_editor.paint_col(p_canvas_grid_size.x - 1, p_grid_line_cells_cmyk)


func _on_apply_button_up() -> void:
	var canvas_grid: Array[Array] = paper_editor.canvas_grid
	var color_keys: Array[String] = []
	var lock_states: Array[bool] = []

	# get the grid colors and lock state
	for row in range(canvas_grid_size.y) :
		for col in range(canvas_grid_size.x) :
			var cell: GridCell = canvas_grid[col][row]

			color_keys.append(cell.color_key())
			lock_states.append(cell.is_ink_locked())

	# create a new LevelData and send it to level editor
	var level_data: LevelData = LevelData.new()
	var level_editor: Control = LEVEL_EDITOR_SCENE.instantiate()

	level_data.set_initial_grid(color_keys, lock_states)

	print(canvas_grid_size)

	level_data.grid_size     = canvas_grid_size
	level_data.paper_color   = paper_editor.get_paper_color()

	level_data.target_colors = color_keys # for init history, basically the base grid
	level_data.lock_states   = lock_states

	# submit LevelData to level_editor
	level_editor.level_data = level_data
	get_tree().change_scene_to_node(level_editor)
