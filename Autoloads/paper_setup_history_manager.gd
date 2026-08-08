extends Node

signal revert_grid_size
signal revert_canvas_grid

class Action :
	var message: String

class PaintingCellAction extends Action :
	var coords := Vector2i.ZERO
	var cell_color_key := "000"
	var cell_lock_state := false

class ResizeCanvasAction extends Action :
	var grid_size := Vector2i.ZERO
	var grid_line_cells_cmyk: Array[String] = []
	var line_axis: LineAxis

class ClearCanvasAction extends Action :
	var canvas_grid_cmyk: Array[Array]


enum LineAxis {
	ROW,
	COL
}


var recorded_actions: Array[Action] = []


func create_painting_cell_action(coords: Vector2i, cell_color_key: String, cell_lock_state: bool) -> Action :
	var action := PaintingCellAction.new()

	action.coords = coords
	action.cell_color_key = cell_color_key
	action.cell_lock_state = cell_lock_state

	return action


func create_resize_canvas_action(grid_size: Vector2i, grid_line_cells_cmyk: Array[String], line_axis: LineAxis) -> Action :
	var action := ResizeCanvasAction.new()

	action.grid_size = grid_size
	action.grid_line_cells_cmyk = grid_line_cells_cmyk
	action.line_axis = line_axis

	return action


func create_clear_canvas_action(canvas_grid_cmyk: Array[Array]) -> Action :
	var action := ClearCanvasAction.new()

	action.canvas_grid_cmyk = canvas_grid_cmyk

	return action
	

func record_action(action: Action) -> void :
	recorded_actions.append(action)



func undo_action(canvas_grid: Array[Array]) -> void :
	if (recorded_actions.is_empty()): return
	
	var prev_action := recorded_actions.pop_back() as Action

	if (prev_action is PaintingCellAction) :
		var col = prev_action.coords.x
		var row = prev_action.coords.y
		var cell: GridCell = canvas_grid[col][row]

		cell.set_color_key(prev_action.cell_color_key)
		cell.toggle_ink_lock(prev_action.cell_lock_state)

	elif (prev_action is ResizeCanvasAction) :
		revert_grid_size.emit(prev_action.grid_size, prev_action.line_axis, prev_action.grid_line_cells_cmyk)

	elif (prev_action is ClearCanvasAction) :
		revert_canvas_grid.emit(prev_action.canvas_grid_cmyk)
