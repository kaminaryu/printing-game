extends Node2D

class_name GridCell

const GRID_CELL_SIZE := Vector2i(128, 128)

@export var highlight_sprite: Sprite2D

var is_paper_editor_mode: bool = false
var ink_locked: bool = false
var c: int = 0
var m: int = 0
var y: int = 0

# this is dumb but idk better way yet
var coords := Vector2i.ZERO

############
# Coloring #
############
# Set colors via key
func set_color_key(new_key: String) -> void:
	if new_key.length() == 3:
		c = int(new_key[0])
		m = int(new_key[1])
		y = int(new_key[2])
		_update_color()
	else:
		printerr("Invalid color key format received: ", new_key)


func apply_ink(channel: String) -> void :
	var is_allowed: bool = _same_color_safeguard(channel)
	if (!is_allowed) :
		return

	match channel :
		"c": c += 1
		"m": m += 1
		"y": y += 1
		_: printerr("Unknown ink channel: %s" % channel)

	_check_for_valid_color()
	_update_color()


func _update_color() -> void :
	var key: String = color_key()
	var hex: String = ColorManager.COLOR_GLOSSARY.get(key, "#676767")
	var target_color: Color = Color.from_string(hex, Color.PURPLE)
	
	var color_tween: Tween = create_tween()
	color_tween.set_trans(Tween.TRANS_LINEAR)
	color_tween.set_ease(Tween.EASE_IN)
	color_tween.tween_property(get_node("GridTexture"), "modulate", target_color, 0.1)


func toggle_ink_lock(toggle = null) -> void :
	if (toggle != null) :
		ink_locked = toggle
	else :
		ink_locked = !ink_locked

	get_node("LockIndicator").visible = ink_locked


##############
# SafeGuards #
##############
# to check if the user is painting the same color (cyan + cyan, etc)
func _same_color_safeguard(channel: String) -> bool :
	match channel :
		"c": return color_key() != "100"
		"m": return color_key() != "010"
		"y": return color_key() != "001"
	return true


# check if the cell is a have a valed color in the dictionary
func _check_for_valid_color() -> void :
	if (ColorManager.COLOR_GLOSSARY.has(color_key())) :
		return

	# set to black
	c=1; m=1; y=1


###########
# Visuals #
###########
func highlight(on: bool) -> void : 
	highlight_sprite.visible = on


###########
# Getters #
###########
func color_key() -> String :
	return "%d%d%d" % [c, m, y]


func is_ink_locked() -> bool :
	return ink_locked

func get_cmyk() -> String :
	return "%s%s" % [color_key(), "1" if is_ink_locked() else "0"]


###########
# Signals #
###########
func _on_mouse_detector_mouse_entered() -> void:
	if (not is_paper_editor_mode): return

	highlight(true)
	CursorManager.set_roller()


func _on_mouse_detector_mouse_exited() -> void:
	if (not is_paper_editor_mode): return

	highlight(false)
	CursorManager.set_cursor()


func _on_mouse_detector_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed and is_paper_editor_mode) :
		if (event.button_index == MOUSE_BUTTON_LEFT) :
			var selected_ink: String = ColorManager.get_color_channel()

			var action := PaperSetupHistoryManager.create_painting_cell_action(
				coords,
				color_key(),
				is_ink_locked(),
				selected_ink,
			)

			# save current size as previous
			PaperSetupHistoryManager.record_action(action)

			if (selected_ink == "k") :
				toggle_ink_lock()
			else :
				if (is_ink_locked()) : return
				apply_ink(selected_ink)
