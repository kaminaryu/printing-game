extends Control

const HISTORY_CARD_SCENE: PackedScene = preload("res://UI/LevelEditor/history_card.tscn")
const LEVEL_EDITOR_SCENE = preload("res://Scenes/LevelEditor/level_editor.tscn")

var canvas_grid_size := Vector2i(5, 5)

@export var paper_editor: Node2D
@export var width_input_box: SpinBox
@export var height_input_box: SpinBox
@export var history_list: VBoxContainer

func _ready() -> void :
	PaperSetupHistoryManager.revert_grid_size.connect(_on_revert_grid_size)
	PaperSetupHistoryManager.revert_canvas_grid.connect(_on_revert_canvas_grid)
	PaperSetupHistoryManager.revert_paper_color.connect(_on_revert_paper_color)
	PaperSetupHistoryManager.history_recorded.connect(_on_history_recorded)
	PaperSetupHistoryManager.history_undone.connect(_on_histoy_undone)

	paper_editor.draw_grid(canvas_grid_size)


func _on_width_input_value_changed(value: float) -> void:
	var grid_line_cells_cmyk: Array[String]

	# save line info if the height decreases
	if (value < canvas_grid_size.x) :
		grid_line_cells_cmyk = paper_editor.get_col_line_cells(canvas_grid_size.x - 1)

	var action := PaperSetupHistoryManager.create_resize_canvas_action(
		canvas_grid_size,
		grid_line_cells_cmyk,
		PaperSetupHistoryManager.LineAxis.COL,
	)

	# save current size as previous
	PaperSetupHistoryManager.record_action(action)

	var is_cloning_grid := true

	canvas_grid_size.x = int(value)
	paper_editor.draw_grid(canvas_grid_size, is_cloning_grid)


func _on_height_input_value_changed(value: float) -> void:
	var grid_line_cells_cmyk: Array[String]

	# save line info if the height decreases
	if (value < canvas_grid_size.y) :
		grid_line_cells_cmyk = paper_editor.get_row_line_cells(canvas_grid_size.y - 1)

	var action := PaperSetupHistoryManager.create_resize_canvas_action(
		canvas_grid_size,
		grid_line_cells_cmyk,
		PaperSetupHistoryManager.LineAxis.ROW,
	)

	# save current size as previous
	PaperSetupHistoryManager.record_action(action)

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

	var is_recording_history := true
	paper_editor.change_paper_color(color_key, is_recording_history)


func _on_undo_button_up() -> void:
	PaperSetupHistoryManager.undo_action(paper_editor.canvas_grid)


func _on_delete_button_up() -> void:
	var canvas_grid_cmyk : Array[Array]

	# copy the current grid cmyk to put into the history
	for col in range(paper_editor.canvas_grid.size()) :
		var canvas_grid_cmyk_column: Array

		for row in range(paper_editor.canvas_grid[col].size()) :
			var cell: GridCell = paper_editor.canvas_grid[col][row]
			canvas_grid_cmyk_column.append(cell.get_cmyk())

		canvas_grid_cmyk.append(canvas_grid_cmyk_column)


	var action := PaperSetupHistoryManager.create_clear_canvas_action(
		canvas_grid_cmyk
	)
	PaperSetupHistoryManager.record_action(action)

	paper_editor.draw_grid(canvas_grid_size)



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


func _on_revert_canvas_grid(p_canvas_grid: Array[Array]) -> void :
	paper_editor.paint_whole_grid(p_canvas_grid)


func _on_revert_paper_color(p_canvas_grid: Array[Array], paper_color_key: String) -> void :
	var is_recording_history := false
	paper_editor.change_paper_color(paper_color_key, is_recording_history)
	paper_editor.paint_whole_grid(p_canvas_grid)


func _on_history_recorded(index: int, msg: String) -> void :
	var history_card: PanelContainer = HISTORY_CARD_SCENE.instantiate()

	history_card.set_values(index, msg)
	history_list.add_child(history_card)
	history_list.move_child(history_card, 0)


func _on_histoy_undone() -> void :
	var latest_history_card = history_list.get_child(0)

	if latest_history_card :
		latest_history_card.queue_free()


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
