extends Control

# --- UI Node References ---
@onready var level_box: SpinBox = $HBoxContainer/PanelContainer/VBoxContainer/Level/LevelBox

@onready var grid_width_box: SpinBox = $HBoxContainer/PanelContainer/VBoxContainer/GridWidth/GridWidthBox
@onready var grid_height_box: SpinBox = $HBoxContainer/PanelContainer/VBoxContainer/GridhHeight/GridHeightBox

@onready var ink_c_box: SpinBox = $HBoxContainer/PanelContainer/VBoxContainer/CyanAmmo/InkCBox
@onready var ink_m_box: SpinBox = $HBoxContainer/PanelContainer/VBoxContainer/MagentaAmmo/InkMBox
@onready var ink_y_box: SpinBox = $HBoxContainer/PanelContainer/VBoxContainer/YellowAmmo/InkYBox
@onready var ink_k_box: SpinBox = $HBoxContainer/PanelContainer/VBoxContainer/KeyAmmo/InkKBox

@onready var save_button: Button = $HBoxContainer/PanelContainer/VBoxContainer/SaveButton

# --- Workspace Grid Reference ---
@onready var printing_grid = $HBoxContainer/CenterContainer/Control/PrintingGrid

var current_grid_size: Vector2i = Vector2i(5, 5)

func _ready() -> void:
	# 2. Tell your PrintingGrid it's in editor mode so it skips ink limits & delays
	if "is_editor_mode" in printing_grid:
		printing_grid.is_editor_mode = true

	# 3. Connect UI changes & buttons
	grid_width_box.value_changed.connect(_on_dimensions_changed)
	grid_height_box.value_changed.connect(_on_dimensions_changed)
	save_button.pressed.connect(_on_save_button_pressed)
	
	# Initial build run
	_refresh_grid_canvas()


func _on_dimensions_changed(_new_value: float) -> void:
	current_grid_size = Vector2i(int(grid_width_box.value), int(grid_height_box.value))
	_refresh_grid_canvas()


func _refresh_grid_canvas() -> void:
	# Clear out your undo/redo stacks when resizing the canvas
	if has_node("/root/SaveStatesManager"):
		SaveStatesManager.reset()
	
	# Pass the size to your existing building system
	printing_grid.setup_and_build(current_grid_size)


## Converts your 2D grid matrix back into a flat 1D Array[String] for the resource
func _flatten_grid_to_1d(matrix_2d: Array) -> Array[String]:
	var flattened: Array[String] = []
	
	# Row-first iteration matches your LevelData row-first unpacking loop
	for row in range(current_grid_size.y):
		for col in range(current_grid_size.x):
			var cell_color_key: String = matrix_2d[col][row]
			
			if cell_color_key.is_empty():
				flattened.append("000") # Fallback to your empty cell string token
			else:
				flattened.append(cell_color_key)
				
	return flattened


func _on_save_button_pressed() -> void:
	var new_level = LevelData.new()
	new_level.grid_size = current_grid_size
	
	# Read the values from your ink SpinBoxes
	new_level.ink_limits = {
		"c": int(ink_c_box.value),
		"m": int(ink_m_box.value),
		"y": int(ink_y_box.value),
		"k": int(ink_k_box.value)
	}
	
	# Ask your PrintingGrid for its current 2D matrix layout array
	# (Ensure your PrintingGrid has a method that returns its data state array!)
	var matrix_2d = printing_grid.get_grid_color_matrix()
	
	# Transform the layout to the 1D structure your script expects
	new_level.target_colors = _flatten_grid_to_1d(matrix_2d)
	
	# Save the file to your levels directory
	var save_path = "res://Resources/Levels/%s.tres" % str(int(level_box.value))
	var error = ResourceSaver.save(new_level, save_path)
	
	if error == OK:
		print("💾 Level successfully created and written to disk at: ", save_path)
	else:
		print("❌ Save failed. Godot error code: ", error)


# --- History controls ---
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("undo") and has_node("/root/SaveStatesManager"):
		SaveStatesManager.undo_action()
	elif event.is_action_pressed("redo") and has_node("/root/SaveStatesManager"):
		SaveStatesManager.redo_action()
	elif event.is_action_pressed("reset_grid"):
		_refresh_grid_canvas()
