extends Node2D

@export var grid_size: Vector2 = Vector2(5, 5)
@export var is_editor_mode: bool = false 
@export var level_editor: Control

@onready var cell_scene = preload("res://Objects/Printer/PrintingGrid/grid_cell.tscn")
@onready var painter_scene = preload("res://Objects/Printer/PrintingGrid/painter.tscn")

@onready var paint_roll_sfx = $"Paint Roll SFX"

const MAX_GRID_BOUNDS: float = 350.0
const CELL_GAP: int = 2
const BUTTON_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000"]
const PAINT_CASCADE_SPEED = 0.06
const CELL_FADE_DURATION = 0.2

var dynamic_square_size: float = 128.0
var step_size: float = 130.0
var center_offset: Vector2 = Vector2.ZERO
var is_cascading: bool = false

var canvas_grid: Array[Array] = []

var default_screen_y: float = 360.0

signal paint_cascade_finished
signal ink_used_in_editor


##################
# Initialization #
##################
func _ready() -> void :
	SaveStatesManager.state_restored.connect(_on_state_restored)
	paint_cascade_finished.connect(func(): is_cascading = false)


func _init_grid() -> void :
	var max_axis_count: float = max(grid_size.x, grid_size.y)
	var available_space: float = MAX_GRID_BOUNDS - ((max_axis_count - 1.0) * CELL_GAP)
	
	dynamic_square_size = floor(available_space / max_axis_count)
	step_size = dynamic_square_size + CELL_GAP
	
	var total_size: Vector2 = grid_size * step_size - Vector2(CELL_GAP, CELL_GAP)
	center_offset = (-(total_size / 2.0) + Vector2(dynamic_square_size / 2.0, dynamic_square_size / 2.0)).floor()

	for col in range(grid_size.x):
		var columns: Array = []

		for row in range(grid_size.y):
			var cell_node: Node2D = cell_scene.instantiate()
			var cell_pos: Vector2 = (Vector2(col, row) * step_size) + center_offset
			cell_node.position = cell_pos.floor()
			
			var sprite: Sprite2D = cell_node.get_node("GridTexture") as Sprite2D
			var target_scale: Vector2 = Vector2.ONE
			
			if sprite and sprite.texture:
				var original_size: Vector2 = sprite.texture.get_size()
				target_scale = Vector2(dynamic_square_size, dynamic_square_size) / original_size
			
			cell_node.scale = target_scale
			add_child(cell_node)
			columns.append(cell_node)

		canvas_grid.append(columns)


func _init_buttons() -> void :
	const MARGIN: float = 48.0
	
	for col in range(grid_size.x):
		var arrow: Node2D = painter_scene.instantiate() as Node2D
		
		var arrow_x: float = (col * step_size) + center_offset.x
		var arrow_y: float = center_offset.y - (dynamic_square_size / 2.0) - MARGIN
		
		arrow.position = Vector2(arrow_x, arrow_y).floor()
		arrow.grid_alignment = "col"
		arrow.grid_index = col
		arrow.paint_requested.connect(_on_paint_request)
		arrow.hovered.connect(_on_arrow_hovered)
		arrow.unhovered.connect(_clear_highlight)
		
		var btn: Button = arrow.get_node("Button") as Button
		if btn:
			btn.size = Vector2(dynamic_square_size, dynamic_square_size)
			btn.position = -btn.size / 2.0
		
		add_child(arrow)

	for row in range(grid_size.y):
		var arrow: Node2D = painter_scene.instantiate() as Node2D
		
		var arrow_x: float = center_offset.x - (dynamic_square_size / 2.0) - MARGIN
		var arrow_y: float = (row * step_size) + center_offset.y
		
		arrow.position = Vector2(arrow_x, arrow_y).floor()
		arrow.grid_alignment = "row"
		arrow.grid_index = row
		arrow.rotation = -PI/2
		arrow.paint_requested.connect(_on_paint_request)
		arrow.hovered.connect(_on_arrow_hovered)
		arrow.unhovered.connect(_clear_highlight)
		
		var btn: Button = arrow.get_node("Button") as Button
		if btn:
			btn.size = Vector2(dynamic_square_size, dynamic_square_size)
			btn.position = -btn.size / 2.0

		add_child(arrow)


# Settiung up the grid for levels loading
func setup_and_build(size: Vector2i) -> void:
	for child in get_children():
		if child is Node2D and child.name != "Paper": 
			child.queue_free()
	
	canvas_grid.clear() 
	grid_size = size
	
	_init_grid()
	_init_buttons()


############
# Painting #
############
func _on_paint_request(request: Dictionary) -> void:
	if is_cascading:
		return

	var alignment: String   = request.get("grid_alignment")
	var index: int          = request.get("grid_index")
	var channel: String     = ColorManager.get_color_channel()
	
	# do not use the ordinary save states and ink counts if in editor mode
	if is_editor_mode:
		match alignment:
			"col": _paint_column(index, channel)
			"row": _paint_row(index, channel)

		# for tracking amount of ink used
		ink_used_in_editor.emit(channel)
		return

	var is_lock_action: bool = (channel == ColorManager.CHANNELS[3])

	is_cascading = true
	SaveStatesManager.save_snapshot(get_grid_color_matrix(), owner.remaining_ink)

	if owner and owner.has_method("use_ink_channel"):
		if not owner.use_ink_channel(channel):
			is_cascading = false 
			SaveStatesManager.undo_action() 
			return

	var _locked_line: bool = false
	match alignment:
		"col":
			_locked_line = _paint_column(index, channel)
		"row":
			_locked_line = _paint_row(index, channel)
			
	if _locked_line:
		is_cascading = false


func _paint_column(col: int, channel: String) -> bool :
	var lock_cell_count: int = 0
	var tween: Tween = create_tween().set_parallel(true)
	var speed_modifier: float = 0.0 if is_editor_mode else PAINT_CASCADE_SPEED
	
	# save to level editor history
	if (is_editor_mode) :
		assert(level_editor, "CONNECT LEVEL EDITOR TO PRINTING CANVAS IN THE LEVEL EDITOR SCENE")
		LevelHistoryManager.save_level_snapshot(
			canvas_grid,
			LevelHistoryManager.Actions.PAINT_COLUMN,
			LevelHistoryManager.LineData.new(col, level_editor.get_ink_counter())
		)

	for row in range(grid_size.y):
		var cell: GridCell = canvas_grid[col][row]

		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		var delay: float = row * speed_modifier
		tween.tween_interval(delay).finished.connect(func():
			var changed_color: bool = cell.apply_ink(channel)
			if (changed_color):
				_update_cell_color(cell)
		)

	var locked: bool = (lock_cell_count == grid_size.y)
	var total_delay: float = (grid_size.y - 1) * speed_modifier + CELL_FADE_DURATION
	paint_roll_sfx.pitch_scale = randf_range(0.8, 1.1)
	paint_roll_sfx.play()
	
	tween.tween_interval(total_delay).finished.connect(func(): paint_cascade_finished.emit())

	return locked


func _paint_row(row: int, channel: String) -> bool :
	var lock_cell_count: int = 0
	var tween: Tween = create_tween().set_parallel(true)
	var speed_modifier: float = 0.0 if is_editor_mode else PAINT_CASCADE_SPEED
	
	# save to level editor history
	if (is_editor_mode) :
		assert(level_editor, "CONNECT LEVEL EDITOR TO PRINTING CANVAS IN THE LEVEL EDITOR SCENE")
		LevelHistoryManager.save_level_snapshot(
			canvas_grid,
			LevelHistoryManager.Actions.PAINT_ROW,
			LevelHistoryManager.LineData.new(row, level_editor.get_ink_counter())
		)

	for col in range(grid_size.x):
		var cell: Node = canvas_grid[col][row]

		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		var delay: float = col * speed_modifier
		
		tween.tween_interval(delay).finished.connect(func():
			var changed_color: bool = cell.apply_ink(channel)
			if (changed_color):
				_update_cell_color(cell)
		)

	var locked: bool = (lock_cell_count == grid_size.x)
	var total_delay: float = (grid_size.x - 1) * speed_modifier + CELL_FADE_DURATION
	
	paint_roll_sfx.pitch_scale = randf_range(0.8, 1.1)
	paint_roll_sfx.play()
	
	tween.tween_interval(total_delay).finished.connect(func(): paint_cascade_finished.emit())

	return locked


func _paint_individual_cell(cell: Node, target_color: String) -> void :
	cell.set_color_key(target_color)
	_update_cell_color(cell)

func _lock_individual_cell(cell: GridCell, lock_state: bool) -> void :
	cell.toggle_ink_lock(lock_state)
	


func _update_cell_color(cell: Node) -> void :
	var key: String = cell.color_key()
	var hex: String = ColorManager.COLOR_GLOSSARY.get(key, "#676767")
	var target_color: Color = Color.from_string(hex, Color.PURPLE)
	
	var color_tween: Tween = create_tween()
	color_tween.set_trans(Tween.TRANS_LINEAR)
	color_tween.set_ease(Tween.EASE_IN)
	color_tween.tween_property(cell.get_node("GridTexture"), "modulate", target_color, 0.1)


###########
# Actions #
###########
func _clear_highlight() -> void:
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var cell: Node = canvas_grid[col][row]
			cell.get_node("HighlightOverlay").hide()


func reset_grid_visuals() -> void:
	if is_editor_mode:
		assert(level_editor, "CONNECT LEVEL EDITOR TO PRINTING CANVAS IN THE LEVEL EDITOR SCENE")
		LevelHistoryManager.save_level_snapshot(
			canvas_grid,
			LevelHistoryManager.Actions.CLEAR_CANVAS,
			level_editor.get_ink_counter(),
		)

	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var cell: Node = canvas_grid[col][row]
			cell.reset()
			_update_cell_color(cell)


func paint_canvas(color_keys: Array[Array]) -> void :
	for col in range(canvas_grid.size()) :
		for row in range(canvas_grid[col].size()) :
			var color_key: String

			# so that out of bounds cell get filled with white
			if (col >= color_keys.size()) :
				color_key = "000"
			elif (row >= color_keys[col].size()) :
				color_key = "000"
			else :
				color_key = color_keys[col][row]

			_paint_individual_cell(canvas_grid[col][row], color_key)


func lock_canvas(lock_states: Array[Array]) -> void :
	for col in range(canvas_grid.size()) :
		for row in range(canvas_grid[col].size()) :
			var lock_state: bool

			# so that out of bounds cell get filled with white
			if (col >= lock_states.size()) :
				lock_state = false
			elif (row >= lock_states[col].size()) :
				lock_state = false
			else :
				lock_state = lock_states[col][row]

			_lock_individual_cell(canvas_grid[col][row], lock_state)




# for changing grid size in editor without deleting painted inks
func resize_grid_without_reset() -> void :
	pass


###########
# Getters #
###########
# returns a 2D array that have the cell data (color and lock_state)
func get_grid_color_matrix() -> Array:
	var matrix: Array = []

	for col in range(grid_size.x):
		var column_data: Array = []

		for row in range(grid_size.y):
			var cell = canvas_grid[col][row]

			# Store a dictionary containing both color and the lock state
			column_data.append({
				"color": cell.color_key(),
				"locked": cell.is_ink_locked()
			})
		matrix.append(column_data)
	return matrix



###########
# Signals #
###########
func _on_state_restored(snapshot: Dictionary) -> void:
	if not snapshot.has("grid") or not snapshot.has("ink"):
		return
		
	var grid_matrix: Array = snapshot["grid"]
	
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var cell_data = grid_matrix[col][row]
			var cell = canvas_grid[col][row]
			
			if cell_data is Dictionary:
				cell.set_color_key(cell_data["color"])
				
				if cell.is_ink_locked() != cell_data["locked"]:
					cell.toggle_ink_lock()
			else:
				cell.set_color_key(cell_data) 
				
			_update_cell_color(cell) 
			
	var level_manager = get_parent()
	if level_manager and "remaining_ink" in level_manager:
		level_manager.remaining_ink = snapshot["ink"].duplicate()
		
		if level_manager.has_signal("ink_inventory_updated"):
			for channel in level_manager.remaining_ink.keys():
				level_manager.ink_inventory_updated.emit(channel, level_manager.remaining_ink[channel])


func _on_arrow_hovered(alignment: String, index: int) -> void :
	if alignment == "col":
		for row in range(grid_size.y):
			var cell: Node = canvas_grid[index][row]
			cell.get_node("HighlightOverlay").show()
	
	elif alignment == "row":
		for col in range(grid_size.x):
			var cell: Node = canvas_grid[col][index]
			cell.get_node("HighlightOverlay").show()
