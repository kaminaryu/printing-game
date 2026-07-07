extends Node2D

@export var grid_size: Vector2 = Vector2(5, 5)

@onready var cell_scene = preload("res://Objects/Printer/PrintingGrid/grid_cell.tscn")
@onready var line_picker_scene = preload("res://Objects/Printer/PrintingGrid/painter.tscn")
@onready var game_manager_scene = $".."

const MAX_GRID_BOUNDS: float = 400.0
const CELL_GAP: int = 2
const BUTTON_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000"]
const PAINT_CASCADE_SPEED = 0.06
const CELL_FADE_DURATION = 0.2

var dynamic_square_size: float = 128.0
var step_size: float = 130.0
var center_offset: Vector2 = Vector2.ZERO

var grid: Array = []

signal paint_cascade_finished

func _ready() -> void :
	
	SaveStatesManager.grid_redraw_request.connect(_set_cell_state)

func setup_and_build(size: Vector2i) -> void:
	grid_size = size
	_init_grid()
	_init_buttons()
	

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
			
			cell_node.scale = Vector2.ZERO
			add_child(cell_node)
			columns.append(cell_node)
			
			_animate_cell_entrance(cell_node, col, row, target_scale)

		grid.append(columns)


func _animate_cell_entrance(cell_node: Node2D, col: int, row: int, target_scale: Vector2) -> void :
	var tween: Tween = create_tween()
	var delay: float = (col * 0.15) + (row * 0.04)
	
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(cell_node, "scale", target_scale, 0.4).set_delay(delay)


func _init_buttons() -> void :
	# Bumped to 48.0 per your previous request for a cleaner structural layout gap
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
		
		arrow.scale = Vector2.ZERO
		add_child(arrow)
		_animate_arrow_entrance(arrow, col, 0)

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

		arrow.scale = Vector2.ZERO
		add_child(arrow)
		_animate_arrow_entrance(arrow, 0, row)


func _animate_arrow_entrance(arrow_node: Node2D, col: int, row: int) -> void:
	var tween: Tween = create_tween()
	var delay: float = 0.1 + (col * 0.15) + (row * 0.15)
	
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(arrow_node, "scale", Vector2.ONE, 0.4).set_delay(delay)


func _on_paint_request(request: Dictionary) -> void :
	var alignment: String   = request.get("grid_alignment")
	var index: int          = request.get("grid_index")
	var channel: String     = ColorManager.get_color_channel()
	
	var can_paint: bool = game_manager_scene.use_ink_channel(channel)
	if not can_paint:
		return # Exit early without updating state or playing animations!

	var locked_line: bool = false
	match alignment:
		"col":
			locked_line = _paint_column(index, channel)
		"row":
			locked_line = _paint_row(index, channel)
		_:
			printerr("Unknown grid alignment: %s" % alignment)

	if (!locked_line) :
		_save_current_state()


func _paint_column(col: int, channel: String) -> bool :
	var lock_cell_count: int = 0
	var tween: Tween = create_tween()
	
	for row in range(grid_size.y):
		var cell: Node = grid[col][row]

		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		var delay: float = row * PAINT_CASCADE_SPEED
		
		tween.tween_callback(func():
			var changed_color: bool = cell.apply_ink(channel)
			if (changed_color):
				_update_cell_color(cell)
		).set_delay(delay)

	var locked: bool = (lock_cell_count == grid_size.y)
	
	# Uses grid_size.y because columns go downwards vertically
	var total_delay: float = (grid_size.y - 1) * PAINT_CASCADE_SPEED + CELL_FADE_DURATION
	tween.tween_callback(func(): paint_cascade_finished.emit()).set_delay(total_delay)
	return locked


func _paint_row(row: int, channel: String) -> bool :
	var lock_cell_count: int = 0
	var tween: Tween = create_tween()
	
	for col in range(grid_size.x):
		var cell: Node = grid[col][row]
		
		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		var delay: float = col * PAINT_CASCADE_SPEED
		
		tween.tween_callback(func():
			var changed_color: bool = cell.apply_ink(channel)
			if (changed_color):
				_update_cell_color(cell)
		).set_delay(delay)

	var locked: bool = (lock_cell_count == grid_size.x)
	
	var total_delay: float = (grid_size.x - 1) * PAINT_CASCADE_SPEED + CELL_FADE_DURATION
	tween.tween_callback(func(): paint_cascade_finished.emit()).set_delay(total_delay)
	return locked

func _save_current_state() -> void :
	SaveStatesManager.increase_step()
	for col in range(grid_size.x) :
		for row in range(grid_size.y) :
			var cell: Node = grid[col][row]
			cell.save_state()

func _set_cell_state(step: String) :
	for col in range(grid_size.x) :
		for row in range(grid_size.y) :
			var cell: Node = grid[col][row]
			cell.set_state(step)
			_update_cell_color(cell)


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


func _reset_all() -> void :
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var cell: Node = grid[col][row]
			cell.reset()
			_update_cell_color(cell)

func _input(event: InputEvent) -> void :
	if event.is_action_pressed("reset_grid"):
		_reset_all()
		SaveStatesManager.reset()
