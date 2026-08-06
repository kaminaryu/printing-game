# level_data.gd
extends Resource
class_name LevelData

@export_subgroup("Level Configuration")
@export var grid_size: Vector2i = Vector2i(5, 5)
@export var available_channels: Array[String] = ColorManager.CHANNELS.duplicate()
@export var level_name: String = "Lorem Ipsum"
@export var paper_color: String = "#FFF"
@export var initial_grid: Array[String]

@export_subgroup("Solution Layout")
@export var target_colors: Array[String] = []
@export var lock_states: Array[bool] = []

@export_subgroup("Ink Limitations")
@export var ink_limits: Dictionary = {
	"c": -1,
	"m": -1,
	"y": -1,
	"k": -1
}

@export_subgroup("Level Editor Metadata")
@export var amount_of_ink_used_cmyk: Array[int] = [0, 0, 0, 0]


func set_available_channels(cyan: bool, magenta: bool, yellow: bool, key: bool) -> void :
	var selected_channels: Array[String] = []

	if (cyan) :
		selected_channels.append("c")
	if (magenta) :
		selected_channels.append("m")
	if (yellow) :
		selected_channels.append("y")
	if (key) :
		selected_channels.append("k")

	available_channels = selected_channels


func set_initial_grid(p_color_keys: Array[String], p_lock_states: Array[bool]) -> void :
	initial_grid = []

	for i in range(p_color_keys.size()) :
		initial_grid.append("%s%s" % [p_color_keys[i], "1" if p_lock_states[i] else "0"])


func get_initial_color_key_by_coords(x: int, y: int) -> String :
	var index: int = x * grid_size.x + y
	var color_key_cmyk: String

	if (index >= initial_grid.size()) :
		color_key_cmyk = "0000"
	else :
		color_key_cmyk = initial_grid[index]

	return color_key_cmyk.substr(0, 3)


func get_initial_lock_states_by_coords(x: int, y: int) -> bool :
	var index: int = x * grid_size.x + y

	if (index >= initial_grid.size()) :
		return false

	return true if initial_grid[index] == "1" else false


# return the end result in a 2D Array of x by y
func get_target_grid_2d() -> Array[Array]:
	var grid_2d: Array[Array] = []
	
	for col in range(grid_size.x):
		grid_2d.append([])
	
	var index: int = 0
	for row in range(grid_size.y):
		for col in range(grid_size.x):
			if index < target_colors.size():
				grid_2d[col].append(target_colors[index])
			else:
				grid_2d[col].append("000")
			index += 1
			
	return grid_2d
	

# return 1d array of lock states into 2d
func get_lock_states_2d() -> Array[Array] :
	var lock_states_2d: Array[Array]

	for col in (grid_size.x) :
		var lock_states_2d_column := []

		for row in range(grid_size.y) :
			var index := col * grid_size.y + row

			if (index < lock_states.size()) :
				lock_states_2d_column.append(lock_states[index])
			else :
				lock_states_2d_column.append(false)

		lock_states_2d.append(lock_states_2d_column)

	return lock_states_2d
