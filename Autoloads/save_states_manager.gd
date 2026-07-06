extends Node

signal grid_redraw_request(current_paint_step: String)

var _current_step: int
var _max_step: int

func _ready() -> void :
	reset()

func reset() -> void :
	_current_step = 0
	_max_step = 0


func get_current_step() -> String :
	return str(_current_step)

func increase_step() -> void :
	_current_step += 1
	_max_step = _current_step


func undo_action() -> void :
	if (_current_step == 0) :
		return

	_current_step -= 1
	grid_redraw_request.emit(get_current_step())
	print("Reverting to step: ", _current_step)

func redo_action() -> void :
	if (_current_step == _max_step) :
		return

	_current_step += 1
	grid_redraw_request.emit(get_current_step())
	print("Reverting to step: ", _current_step)
