extends Node

signal revert_grid_size

class Action :
	var action_type: ActionType
	# for painting cell
	var coords := Vector2i.ZERO
	var cell_color_key := "000"
	var cell_lock_state := false
	# for resizing grid
	var grid_size := Vector2i.ZERO
	var grid_line_cells_cmyk: Array[String] = []
	var line_axis: LineAxis


enum LineAxis {
	ROW,
	COL
}

enum ActionType {
	PAINT_CELL,
	RESIZE_CANVAS
}


var recorded_actions: Array[Action] = []


func record_action(action_type: ActionType, data: Dictionary) -> void :
	var action := Action.new()

	action.action_type = action_type

	match action_type :
		ActionType.PAINT_CELL :
			action.coords = data["coords"]
			action.cell_color_key = data["cell_color_key"]
			action.cell_lock_state = data["cell_lock_state"]
		 	# snapshot_msg = "Printed %s ink at cell (%d, %d)" % []

		ActionType.RESIZE_CANVAS :
			print("tf u mean ", data["grid_line_cells_cmyk"])
			action.grid_size = data["grid_size"]
			action.grid_line_cells_cmyk = data["grid_line_cells_cmyk"]
			action.line_axis = data["line_axis"]
		

	recorded_actions.append(action)

	print(recorded_actions)

	


func undo_action(canvas_grid: Array[Array]) -> void :
	if (recorded_actions.is_empty()): return
	
	var prev_action := recorded_actions.pop_back() as Action

	match prev_action.action_type :
		ActionType.PAINT_CELL :
			var col = prev_action.coords.x
			var row = prev_action.coords.y
			var cell: GridCell = canvas_grid[col][row]

			cell.set_color_key(prev_action.cell_color_key)
			cell.toggle_ink_lock(prev_action.cell_lock_state)

		ActionType.RESIZE_CANVAS :
			revert_grid_size.emit(prev_action.grid_size, prev_action.line_axis, prev_action.grid_line_cells_cmyk)
