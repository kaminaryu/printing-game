extends Node

# NOTE: this is to save each grid edits inside the level editor (WIP)

enum Actions {
	INIT,
	PAINT_COLUMN,
	PAINT_ROW,
	PAINT_CELL,
	CLEAR_CANVAS
}

var _history: Array[LevelSnapshot] = []
# var num_of_actions: int = 0  # for redo


class LevelSnapshot :
	# 2D Array of "cmy" String
	var color_keys: Array[Array]
	var lock_states: Array[Array]
	var message: String
	var step_num: int


# -- methods -- 
func init_level_history(level_data: LevelData) -> void :
	var color_keys: Array[Array] = level_data.get_target_grid_2d()
	save_level_snapshot(color_keys, Actions.INIT)


func save_level_snapshot(canvas_grid: Array[Array], action: Actions, data=null) -> void :
	var snapshot := LevelSnapshot.new()
	var color_keys: Array[Array] = []
	var lock_states: Array[Array] = []

	# if already receive color_keys as canvas_grid, no need to rebuild color_keys
	if action == Actions.INIT:
		color_keys = canvas_grid  # use directly

		for col in range(canvas_grid.size()) :
			var lock_states_column = []

			for row in range(canvas_grid[col].size()) :
				lock_states_column.append(false)

			lock_states.append(lock_states_column)
	
	# deconstruct 2D Array of GridCells into their metadatas
	else :
		for col in range(canvas_grid.size()) :
			var color_keys_column = []
			var lock_states_column = []

			for row in range(canvas_grid[col].size()) :
				var cell: GridCell = canvas_grid[col][row]
				var color_key: String = cell.color_key()
				var lock_state: bool = cell.is_ink_locked()

				color_keys_column.append(color_key)
				lock_states_column.append(lock_state)

			color_keys.append(color_keys_column)
			lock_states.append(lock_states_column)


	match action :
		Actions.PAINT_COLUMN :
			snapshot.message = "Printed a line of ink at column %d" % data


	snapshot.color_keys = color_keys
	snapshot.lock_states = lock_states
	snapshot.step_num = _history.size()
	_history.append(snapshot)

	print("Saving state #%d: " %_history.size())
	print(_history)


func undo_level_edit() -> LevelSnapshot :
	if (_history.size() <= 1) :
		return null

	# remove the latest snapshot
	return _history.pop_back()


func clean_history() -> void :
	_history = []
