extends Node2D

var ink_locked: bool = false
var c: int = 0
var m: int = 0
var y: int = 0

# CLEANED: Removed the old saved_color and saved_lock dictionaries entirely

func _ready() -> void :
	pass

## NEW FUNCTION: Decodes the central snapshot string back into live cell integers
func set_color_key(new_key: String) -> void:
	if new_key.length() == 3:
		c = int(new_key[0])
		m = int(new_key[1])
		y = int(new_key[2])
	else:
		printerr("Invalid color key format received: ", new_key)

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
	c = 0; m = 0; y = 0
	toggle_ink_lock(false)
