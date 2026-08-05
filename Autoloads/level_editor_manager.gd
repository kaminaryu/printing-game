extends Node

# save level data so that level_editor can just load,
# and we set the data from level loader and paper editor
var level_name: String
var grid_size := Vector2i(5, 5)
var color_keys: Array[Array] = []
var lock_states: Array[Array] = []
var level_num: int = 1
var amount_of_ink_used_cmyk: Array[int] = [0, 0, 0, 0]
var ink_limits: Dictionary = {"c": -1, "m": -1, "y": -1, "k": -1}
var available_channels := ["c", "m", "y", "k"]
