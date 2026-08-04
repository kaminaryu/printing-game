extends Control

@export var level_editor_menu: Control
@export var blur_panel: Panel
@export var menu_body: Control

@export var level_name_input_box: LineEdit

@export var grid_width_input_box: SpinBox
@export var grid_height_input_box: SpinBox

@export var ink_c: HBoxContainer
@export var ink_m: HBoxContainer
@export var ink_y: HBoxContainer
@export var ink_k: HBoxContainer

@export var printing_canvas: Node2D


var current_grid_size: Vector2i = Vector2i(5, 5)


func slide_menu() -> void:
	var slide = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true);
	
	# shit is already opened
	if get_tree().paused:
		slide.tween_property(menu_body, "position:x", 1280, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 0, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);

		await slide.finished;
	
		get_tree().paused = false;
		blur_panel.visible = false;

	else:
		slide.tween_property(menu_body, "position:x", 735, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 2.5, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);

		get_tree().paused = true;
		blur_panel.visible = true;



func _ready() -> void:
	# Set printing grid to editor mode so that it wont consume ink and such like a normal gameplay
	if "is_editor_mode" in printing_canvas:
		printing_canvas.is_editor_mode = true

	# Set the grid size fields to the default value
	# (MUST BE before connecting the signals to avoid zeroing current_grid_size on setting width)
	grid_width_input_box.value  = current_grid_size.x
	grid_height_input_box.value = current_grid_size.y

	# Connect UI via code because the UI is defined by exported vars (this is to make that they are modular)
	grid_width_input_box.value_changed.connect(_on_dimensions_changed)
	grid_height_input_box.value_changed.connect(_on_dimensions_changed)


# Converts 2D grid matrix back into a flat 1D Array[String] for the resource
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


func _get_parent() -> Control :
	var parent_name: String = "LevelEditor"
	var parent: Control = get_parent()

	assert(
		parent.name == parent_name,
		"ERROR: LEVEL EDITOR MENU MUST BE THE CHILD OF LEVEL EDITOR (Expected Parent Name: %s | Current Parent Name: %s)" % [parent_name, parent.name]
	)

	return parent


func load_level_metadata(level_data: LevelData) -> void :
	level_name_input_box.text = level_data.level_name
	
	grid_width_input_box.value  = level_data.grid_size.x
	grid_height_input_box.value = level_data.grid_size.y

	ink_c.get_node("SpinBox").value = level_data.ink_limits["c"]
	ink_m.get_node("SpinBox").value = level_data.ink_limits["m"]
	ink_y.get_node("SpinBox").value = level_data.ink_limits["y"]
	ink_k.get_node("SpinBox").value = level_data.ink_limits["k"]

	ink_c.get_node("ToggleVisibility").button_pressed = level_data.available_channels.has("c")
	ink_m.get_node("ToggleVisibility").button_pressed = level_data.available_channels.has("m")
	ink_y.get_node("ToggleVisibility").button_pressed = level_data.available_channels.has("y")
	ink_k.get_node("ToggleVisibility").button_pressed = level_data.available_channels.has("k")


func save_level_metadata(level_num: int) -> void :
	var new_level = LevelData.new()
	new_level.grid_size = current_grid_size
	
	# set ink limits
	new_level.ink_limits = {
		"c": int(ink_c.get_node("SpinBox").value),
		"m": int(ink_m.get_node("SpinBox").value),
		"y": int(ink_y.get_node("SpinBox").value),
		"k": int(ink_k.get_node("SpinBox").value)
	}

	# set avaiable color channel
	# toggle by checking if the button is pressed (shown)
	new_level.set_available_channels(
		ink_c.get_node("ToggleVisibility").button_pressed,
		ink_m.get_node("ToggleVisibility").button_pressed,
		ink_y.get_node("ToggleVisibility").button_pressed,
		ink_k.get_node("ToggleVisibility").button_pressed,
	)

	# get the amount of ink used 
	var level_editor: Control = _get_parent()
	new_level.amount_of_ink_used_cmyk = level_editor.get_ink_counter()

	# other metadatas
	new_level.level_name = level_name_input_box.text
	
	var matrix_2d = printing_canvas.get_grid_color_matrix()
	
	# Transform 2D matrix to 1D Array
	new_level.target_colors = _flatten_grid_to_1d(matrix_2d)
	
	# Attempt to save the level data
	var save_path = "res://Resources/Levels/%d.tres" % level_num
	var response = ResourceSaver.save(new_level, save_path)
	
	if response == OK:
		print("Level successfully created and written to disk at: ", save_path)
	else:
		print("Save failed. Godot error code: ", response)


# --- Signals ---
func _on_back_button_down() -> void:
	slide_menu()
	var level_editor: Control = _get_parent()
	level_editor.put_panel_on_top(self)


func _on_dimensions_changed(_new_value: float) -> void:
	# change the grid size
	current_grid_size = Vector2i(int(grid_width_input_box.value), int(grid_height_input_box.value))

	var parent_name: String = "LevelEditor"
	var level_editor: Control = get_parent()

	assert(
		level_editor.name == parent_name,
		"ERROR: LEVEL EDITOR MENU MUST BE THE CHILD OF LEVEL EDITOR (Expected Parent Name: %s | Current Parent Name: %s)" % [parent_name, level_editor.name]
	)

	level_editor.redraw_grid_canvas(current_grid_size)


func _on_level_num_change() -> void :
	pass


func _on_settings_button_mouse_entered() -> void:
	# shit is already opened no need to wiggle it
	if get_tree().paused: return

	var tween = create_tween();
	tween.tween_property(menu_body, "position:x", 1280-10, .2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)

	var level_editor: Control = _get_parent()
	level_editor.put_panel_on_top(self)


func _on_settings_button_mouse_exited() -> void:
	# shit is already opened no need to wiggle it
	if get_tree().paused: return

	var tween = create_tween();
	tween.tween_property(menu_body, "position:x", 1280, .2);
