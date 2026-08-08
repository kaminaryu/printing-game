extends Node

signal history_added
signal history_removed
signal history_cleaned

enum Actions {
	INIT,
	PAINT_COLUMN,
	PAINT_ROW,
	CLEAR_CANVAS
}

var _history: Array[LevelSnapshot] = []
# var num_of_actions: int = 0  # for redo

# to save / keeptrack which line (row/col) is being painted and saved
class LineData :
	var ink_channel: String = "Undefined"
	var line_num: int
	var ink_counter: Array[int]

	# p_var is a convention that avoid shadowing class attr, its dumb because i like self.var = var ffs
	func _init(p_ink_channel: String, p_line_num: int, p_ink_counter: Array[int]) -> void :
		line_num = p_line_num
		ink_counter = p_ink_counter

		match p_ink_channel :
			"c": ink_channel = "Cyan"
			"m": ink_channel = "Magenta"
			"y": ink_channel = "Yellow"
			"k": ink_channel = "Key"


class LevelSnapshot :
	var color_keys: Array[Array] # 2D Array of "cmy" String
	var lock_states: Array[Array]
	var step_num: int
	var ink_counter: Array[int] = [0, 0, 0, 0]


# -- methods -- 
func init_level_history(color_keys: Array[Array], amount_of_ink_used_cmyk: Array[int]) -> void :
	clean_history()
	save_level_snapshot(color_keys, Actions.INIT, amount_of_ink_used_cmyk)


func save_level_snapshot(canvas_grid: Array[Array], action: Actions, data=null) -> void :
	var snapshot := LevelSnapshot.new()
	var color_keys: Array[Array] = []
	var lock_states: Array[Array] = []
	var snapshot_msg: String = "Message isn't defined"

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
			var color_hex_code: String = ColorManager.get_channel_hexcode(data.ink_channel)
			snapshot_msg = "Printed a line of [color=%s]%s[/color] ink at col %d." % [color_hex_code, data.ink_channel, data.line_num + 1]
		Actions.PAINT_ROW :
			var color_hex_code: String = ColorManager.get_channel_hexcode(data.ink_channel)
			snapshot_msg = "Printed a line of [color=%s]%s[/color] ink at row %d." % [color_hex_code, data.ink_channel, data.line_num + 1]
		Actions.CLEAR_CANVAS :
			snapshot_msg = "Cleared the canvas."
		Actions.INIT :
			snapshot_msg = "First initialization of the canvas."


	snapshot.color_keys = color_keys
	snapshot.lock_states = lock_states
	snapshot.step_num = _history.size()

	# set ink counter
	if (action in [Actions.PAINT_COLUMN, Actions.PAINT_ROW]) :
		snapshot.ink_counter = data.ink_counter
	elif (action == Actions.CLEAR_CANVAS) :
		snapshot.ink_counter = data # (level_editor.get_ink_counter())

	elif (action == Actions.INIT) :
		snapshot.ink_counter = data # (LevelData.amount_of_ink_used_cmyk)

	_history.append(snapshot)

	# create history card
	history_added.emit(_history.size(), snapshot_msg)

	print("Saving state #%d: " %_history.size())
	print(_history)



func undo_level_edit() -> LevelSnapshot :
	if (_history.size() <= 1) :
		return null

	history_removed.emit()
	# remove the latest snapshot
	return _history.pop_back()


func clean_history() -> void :
	_history = []
	history_cleaned.emit()
