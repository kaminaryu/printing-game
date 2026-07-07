extends Node2D

@export var grid_size: Vector2 = Vector2(5, 5)
@export var is_editor_mode: bool = false 

@onready var cell_scene = preload("res://Objects/Printer/PrintingGrid/grid_cell.tscn")
@onready var line_picker_scene = preload("res://Objects/Printer/PrintingGrid/painter.tscn")

const MAX_GRID_BOUNDS: float = 350.0
const CELL_GAP: int = 2
const BUTTON_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000"]
const PAINT_CASCADE_SPEED = 0.06
const CELL_FADE_DURATION = 0.2

var dynamic_square_size: float = 128.0
var step_size: float = 130.0
var center_offset: Vector2 = Vector2.ZERO
var is_cascading: bool = false

var grid: Array = []

var default_screen_y: float = 360.0

signal paint_cascade_finished

func _ready() -> void :
	SaveStatesManager.state_restored.connect(_on_state_restored)
	paint_cascade_finished.connect(func(): is_cascading = false)

func setup_and_build(size: Vector2i) -> void:
	for child in get_children():
		if child is Node2D and child.name != "Paper": 
			child.queue_free()
	
	grid.clear() 
	grid_size = size
	
	_init_grid()
	_init_buttons()
	
	_animate_entrance_from_top()
	

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
			
			# REMOVED: cell_node.scale = Vector2.ZERO setup
			cell_node.scale = target_scale
			add_child(cell_node)
			columns.append(cell_node)

		grid.append(columns)


func _init_buttons() -> void :
	const MARGIN: float = 48.0
	
	for col in range(grid_size.x):
		var arrow: Node2D = line_picker_scene.instantiate() as Node2D
		
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
		
		# REMOVED: arrow.scale = Vector2.ZERO setup
		add_child(arrow)

	for row in range(grid_size.y):
		var arrow: Node2D = line_picker_scene.instantiate() as Node2D
		
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

		# REMOVED: arrow.scale = Vector2.ZERO setup
		add_child(arrow)


## Animates the entire grid entering from above the viewport window
func _animate_entrance_from_top() -> void:
	# Instantly teleport the container way above the visible camera space
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	# Slide smoothly down into the default gameplay center position
	tween.tween_property(self, "position:y", default_screen_y, 1)


## Public function called by your main level controller during a victory match event[cite: 4]
func animate_exit_to_bottom() -> void:
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	# Slide downward off the bottom edge of the viewport
	tween.tween_property(self, "position:y", default_screen_y + 800.0, 0.5)

func _on_paint_request(request: Dictionary) -> void:
	# BLOCK INPUT: If a cascade is currently active, ignore new paint requests entirely
	if is_cascading:
		return

	var alignment: String   = request.get("grid_alignment")
	var index: int          = request.get("grid_index")
	var channel: String     = ColorManager.get_color_channel()
	
	if is_editor_mode:
		match alignment:
			"col": _paint_column(index, channel)
			"row": _paint_row(index, channel)
		return

	var is_lock_action: bool = (channel == ColorManager.CHANNELS[3])

	# If it's a real coloring action, trip the lock before doing anything else
	if not is_lock_action:
		is_cascading = true
		SaveStatesManager.save_snapshot(get_grid_color_matrix(), owner.remaining_ink)

	if owner and owner.has_method("use_ink_channel"):
		if not owner.use_ink_channel(channel):
			if not is_lock_action:
				is_cascading = false # Reset if ink usage failed
				SaveStatesManager.undo_action() 
			return

	var _locked_line: bool = false
	match alignment:
		"col":
			_locked_line = _paint_column(index, channel)
		"row":
			_locked_line = _paint_row(index, channel)
			
	# If the row/col was entirely locked, no cascade animation happens. 
	# Reset the flag immediately so the player isn't stuck.
	if _locked_line:
		is_cascading = false


func _paint_column(col: int, channel: String) -> bool :
	var lock_cell_count: int = 0
	var tween: Tween = create_tween()
	var speed_modifier: float = 0.0 if is_editor_mode else PAINT_CASCADE_SPEED
	
	for row in range(grid_size.y):
		var cell: Node = grid[col][row]

		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		var delay: float = row * speed_modifier
		
		tween.tween_callback(func():
			var changed_color: bool = cell.apply_ink(channel)
			if (changed_color):
				_update_cell_color(cell)
		).set_delay(delay)

	var locked: bool = (lock_cell_count == grid_size.y)
	var total_delay: float = (grid_size.y - 1) * speed_modifier + CELL_FADE_DURATION
	tween.tween_callback(func(): paint_cascade_finished.emit()).set_delay(total_delay)
	return locked


func _paint_row(row: int, channel: String) -> bool :
	var lock_cell_count: int = 0
	var tween: Tween = create_tween()
	var speed_modifier: float = 0.0 if is_editor_mode else PAINT_CASCADE_SPEED
	
	for col in range(grid_size.x):
		var cell: Node = grid[col][row]
		
		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		var delay: float = col * speed_modifier
		
		tween.tween_callback(func():
			var changed_color: bool = cell.apply_ink(channel)
			if (changed_color):
				_update_cell_color(cell)
		).set_delay(delay)

	var locked: bool = (lock_cell_count == grid_size.x)
	var total_delay: float = (grid_size.x - 1) * speed_modifier + CELL_FADE_DURATION
	tween.tween_callback(func(): paint_cascade_finished.emit()).set_delay(total_delay)
	return locked


func get_grid_color_matrix() -> Array:
	var matrix: Array = []
	for col in range(grid_size.x):
		var column_data: Array = []
		for row in range(grid_size.y):
			column_data.append(grid[col][row].color_key())
		matrix.append(column_data)
	return matrix


func _on_state_restored(snapshot: Dictionary) -> void:
	if not snapshot.has("grid") or not snapshot.has("ink"):
		return
		
	var color_matrix: Array = snapshot["grid"]
	
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var target_color_key: String = color_matrix[col][row]
			grid[col][row].set_color_key(target_color_key) 
			_update_cell_color(grid[col][row]) 
			
	var level_manager = get_parent()
	if level_manager and "remaining_ink" in level_manager:
		level_manager.remaining_ink = snapshot["ink"].duplicate()
		
		if level_manager.has_signal("ink_inventory_updated"):
			for channel in level_manager.remaining_ink.keys():
				level_manager.ink_inventory_updated.emit(channel, level_manager.remaining_ink[channel])


func _update_cell_color(cell: Node) -> void :
	var key: String = cell.color_key()
	var hex: String = ColorManager.COLOR_GLOSSARY.get(key, "#676767")
	var target_color: Color = Color.from_string(hex, Color.PURPLE)
	
	var color_tween: Tween = create_tween()
	color_tween.set_trans(Tween.TRANS_LINEAR)
	color_tween.set_ease(Tween.EASE_IN)
	color_tween.tween_property(cell.get_node("GridTexture"), "modulate", target_color, 0.1)


func _on_arrow_hovered(alignment: String, index: int) -> void:
	if alignment == "col":
		for row in range(grid_size.y):
			var cell: Node = grid[index][row]
			cell.get_node("HighlightOverlay").visible = true
	
	elif alignment == "row":
		for col in range(grid_size.x):
			var cell: Node = grid[col][index]
			cell.get_node("HighlightOverlay").visible = true


func _clear_highlight() -> void:
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var cell: Node = grid[col][row]
			cell.get_node("HighlightOverlay").visible = false


func reset_grid_visuals() -> void:
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var cell: Node = grid[col][row]
			cell.reset()
			_update_cell_color(cell)
