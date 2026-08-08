extends Node

signal revert_grid_size
signal revert_canvas_grid
signal history_recorded
signal history_undone

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


func create_painting_cell_action(coords: Vector2i, cell_color_key: String, cell_lock_state: bool, channel: String) -> Action :
	var action := PaintingCellAction.new()
	var channel_hex_code := ColorManager.get_channel_hexcode(channel)
	var channel_name := ColorManager.get_channel_name(channel)

	action.message = "Colored Cell(%d, %d) with [color=%s]%s[/color] ink." % [coords.x, coords.y, channel_hex_code, channel_name]
	action.coords = coords
	action.cell_color_key = cell_color_key
	action.cell_lock_state = cell_lock_state

	return action


func create_resize_canvas_action(grid_size: Vector2i, grid_line_cells_cmyk: Array[String], line_axis: LineAxis) -> Action :
	var action := ResizeCanvasAction.new()

	action.message = "Resized the canvas to size(%d, %d)." % [grid_size.x, grid_size.y]
	action.grid_size = grid_size
	action.grid_line_cells_cmyk = grid_line_cells_cmyk
	action.line_axis = line_axis

	return action


func create_clear_canvas_action(canvas_grid_cmyk: Array[Array]) -> Action :
	var action := ClearCanvasAction.new()

	action.message = "Cleared the canvas."
	action.canvas_grid_cmyk = canvas_grid_cmyk

	return action
	

func record_action(action: Action) -> void :
	recorded_actions.append(action)

	history_recorded.emit(recorded_actions.size(), action.message)



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

	history_undone.emit()
