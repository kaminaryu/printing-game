extends Node2D

var ink_locked: bool = false
var c: int = 0
var m: int = 0
var y: int = 0
var saved_color: Dictionary
var saved_lock: Dictionary


func _ready() -> void :
	saved_color = {"0": "000"}
	saved_lock = {"0": false}

func save_state() -> void :
	var current_step: String = SaveStatesManager.get_current_step()
	saved_color[current_step] = color_key()
	saved_lock[current_step]  = is_ink_locked()

func _same_color_safeguard(channel: String) -> bool :
	match channel :
		"c": return color_key() != "100"
		"m": return color_key() != "010"
		"y": return color_key() != "001"
	return true

func apply_ink(channel: String) -> bool :
	var is_allowed: bool = _same_color_safeguard(channel)
	if (!is_allowed) :
		return false

	match channel :
		"c": c += 1
		"m": m += 1
		"y": y += 1
		_: printerr("Unknown ink channel: %s" % channel)

	_check_for_valid_color()

	return true


func _check_for_valid_color() -> void :
	if (ColorManager.COLOR_GLOSSARY.has(color_key())) :
		return

	# set to black
	c=1; m=1; y=1


func set_state(step: String) -> void :
	var saved_color_key = saved_color[step]
	toggle_ink_lock(saved_lock[step])
	c = int(saved_color_key[0])
	m = int(saved_color_key[1])
	y = int(saved_color_key[2])


func color_key() -> String :
	return "%d%d%d" % [c, m, y]


func toggle_ink_lock(toggle = null) -> void :
	if (toggle != null) :
		ink_locked = toggle
	else :
		ink_locked = !ink_locked

	get_node("LockIndicator").visible = ink_locked


func is_ink_locked() -> bool :
	return ink_locked


func reset() -> void :
	c = 0 ;m = 0; y = 0
	toggle_ink_lock(false)
	saved_color = {"0": "000"}
	saved_lock = {"0": false}
