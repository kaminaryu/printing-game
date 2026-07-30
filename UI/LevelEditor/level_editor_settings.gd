extends Control


@export var level_editor_menu: Control

@export var level_name_input_box: LineEdit

@export var grid_width_input_box: SpinBox
@export var grid_height_input_box: SpinBox

@export var ink_c_input_box: SpinBox
@export var ink_m_input_box: SpinBox
@export var ink_y_input_box: SpinBox
@export var ink_k_input_box: SpinBox

@export var save_level_button: Button

# --- Workspace Grid Reference ---
@export var printing_grid: Node2D


func open() -> void :
	show()
	create_tween().tween_property(self, "position:x", 0, .4).from(655).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);


func close() -> void :
	await create_tween().tween_property(self, "position:x", 655, .4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).finished;
	hide()


func _on_back_button_down() -> void:
	close()


var current_grid_size: Vector2i = Vector2i(5, 5)

func _ready() -> void:
	# Set printing grid to editor mode so that it wont consume ink and such like a normal gameplay
	if "is_editor_mode" in printing_grid:
		printing_grid.is_editor_mode = true

	# Set the grid size fields to the default value
	# (MUST BE before connecting the signals to avoid zeroing current_grid_size on setting width)
	grid_width_input_box.value  = current_grid_size.x
	grid_height_input_box.value = current_grid_size.y

	# Connect UI via code because the UI is defined by exported vars (this is to make that they are modular)
	grid_width_input_box.value_changed.connect(_on_dimensions_changed)
	grid_height_input_box.value_changed.connect(_on_dimensions_changed)
	save_level_button.pressed.connect(_on_save_level_button_pressed)

	
	_redraw_grid_canvas()


func _on_dimensions_changed(_new_value: float) -> void:
	current_grid_size = Vector2i(int(grid_width_input_box.value), int(grid_height_input_box.value))
	_redraw_grid_canvas()


func _redraw_grid_canvas() -> void:
	# Clear paint history
	if has_node("/root/SaveStatesManager"):
		SaveStatesManager.reset()
	
	printing_grid.setup_and_build(current_grid_size)


## Converts 2D grid matrix back into a flat 1D Array[String] for the resource
func _flatten_grid_to_1d(matrix_2d: Array) -> Array[String]:
	var flattened: Array[String] = []
	
	# Row-first iteration matches LevelData row-first unpacking loop
	for row in range(current_grid_size.y):
		for col in range(current_grid_size.x):
			var cell_color_key: String = matrix_2d[col][row]["color"]
			
			if cell_color_key.is_empty():
				flattened.append("000")
			else:
				flattened.append(cell_color_key)
				
	return flattened


func _on_save_level_button_pressed() -> void:
	var new_level = LevelData.new()
	new_level.grid_size = current_grid_size
	
	new_level.ink_limits = {
		"c": int(ink_c_input_box.value),
		"m": int(ink_m_input_box.value),
		"y": int(ink_y_input_box.value),
		"k": int(ink_k_input_box.value)
	}

	new_level.level_name = level_name_input_box.text
	
	var matrix_2d = printing_grid.get_grid_color_matrix()
	
	# Transform 2D matrix to 1D Array
	new_level.target_colors = _flatten_grid_to_1d(matrix_2d)
	
	# Attempt to save the level data
	var save_path = "res://Resources/Levels/%s.tres" % str(int(level_editor_menu.selected_level))
	var error = ResourceSaver.save(new_level, save_path)
	
	if error == OK:
		print("Level successfully created and written to disk at: ", save_path)
	else:
		print("Save failed. Godot error code: ", error)


# --- History controls ---
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("undo"):
		SaveStatesManager.undo_action()
	elif event.is_action_pressed("redo"):
		SaveStatesManager.redo_action()
	elif event.is_action_pressed("reset_grid"):
		_redraw_grid_canvas()
