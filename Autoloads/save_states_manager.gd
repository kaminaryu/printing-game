extends Node

signal state_restored(snapshot: Dictionary)

var _current_step: int = 0
var _max_step: int = 0

var _history: Dictionary = {}

func _ready() -> void:
	reset()

func reset() -> void:
	_current_step = 0
	_max_step = 0
	_history.clear()

func save_snapshot(grid_matrix: Array, ink_limits: Dictionary) -> void:
	if _current_step < _max_step:
		for i in range(_current_step + 1, _max_step + 1):
			_history.erase(i)
			
	_history[_current_step] = {
		"grid": grid_matrix.duplicate(true),
		"ink": ink_limits.duplicate()
	}
	
	_current_step += 1
	_max_step = _current_step

func undo_action() -> void:
	if _current_step == 0:
		return

	_current_step -= 1
	print("Reverting to step: ", _current_step)
	state_restored.emit(_history[_current_step])

func redo_action() -> void:
	if _current_step == _max_step:
		return

	_current_step += 1
	print("Advancing to step: ", _current_step)
	state_restored.emit(_history[_current_step])
	
