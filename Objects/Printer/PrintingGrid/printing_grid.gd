extends Node2D

@export var grid_size: Vector2 = Vector2(5, 5)

@onready var square_scene = preload("res://Objects/Printer/PrintingGrid/grid_square.tscn")
@onready var line_picker_scene = preload("res://Objects/Printer/PrintingGrid/painter.tscn")

const MAX_GRID_BOUNDS: float = 300.0
const CELL_GAP: int = 2
const BUTTON_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000"]

var dynamic_square_size: float = 128.0
var step_size: float = 130.0
var center_offset: Vector2 = Vector2.ZERO

class GridCell :
	var this: Node2D
	var ink_locked: bool = false
	var c: int = 0
	var m: int = 0
	var y: int = 0
	var saved_color: Dictionary
	var saved_lock: Dictionary

	func _init(p_node: Node2D) -> void :
		this = p_node
		saved_color = {"0": "000"}
		saved_lock = {"0": false}

	func save_state() -> void :
		var current_step: String = SaveStatesManager.get_current_step()
		saved_color[current_step] = color_key()
		saved_lock[current_step]  = is_ink_locked()
		print(saved_color)

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
		this.get_node("LockIndicator").visible = ink_locked

	func is_ink_locked() -> bool :
		return ink_locked

	func reset() -> void :
		c = 0 ;m = 0; y = 0
		toggle_ink_lock(false)
		saved_color = {"0": "000"}
		saved_lock = {"0": false}

var grid: Array = []

func _ready() -> void :
	_init_grid()
	_init_buttons()
	SaveStatesManager.grid_redraw_request.connect(_set_cell_state)

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
			var cell_node: Node2D = square_scene.instantiate()
			var cell_pos: Vector2 = (Vector2(col, row) * step_size) + center_offset
			cell_node.position = cell_pos.floor()
			
			var sprite: Sprite2D = cell_node.get_node("GridTexture") as Sprite2D
			var target_scale: Vector2 = Vector2.ONE
			
			if sprite and sprite.texture:
				var original_size: Vector2 = sprite.texture.get_size()
				target_scale = Vector2(dynamic_square_size, dynamic_square_size) / original_size
			
			cell_node.scale = Vector2.ZERO
			add_child(cell_node)
			columns.append(GridCell.new(cell_node))
			
			_animate_cell_entrance(cell_node, col, row, target_scale)

		grid.append(columns)

func _animate_cell_entrance(cell_node: Node2D, col: int, row: int, target_scale: Vector2) -> void :
	var tween: Tween = create_tween()
	var delay: float = (col * 0.15) + (row * 0.04)
	
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(cell_node, "scale", target_scale, 0.4).set_delay(delay)

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
	for row in range(grid_size.y):
		var cell: GridCell = grid[col][row]

		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		var changed_color: bool = cell.apply_ink(channel)

		if (!changed_color) :
			lock_cell_count += 1
			continue

		_update_cell_color(cell)

	var locked: bool = (lock_cell_count == grid_size.y)
	return locked


func _paint_row(row: int, channel: String) -> bool :
	var lock_cell_count: int = 0
	for col in range(grid_size.x):
		var cell: GridCell = grid[col][row]
		
		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		var changed_color: bool = cell.apply_ink(channel)

		if (!changed_color) :
			lock_cell_count += 1
			continue

		_update_cell_color(cell)

	var locked: bool = (lock_cell_count == grid_size.x)
	return locked

func _save_current_state() -> void :
	SaveStatesManager.increase_step()
	for col in range(grid_size.x) :
		for row in range(grid_size.y) :
			var cell: GridCell = grid[col][row]
			cell.save_state()

func _set_cell_state(step: String) :
	for col in range(grid_size.x) :
		for row in range(grid_size.y) :
			var cell: GridCell = grid[col][row]
			cell.set_state(step)
			_update_cell_color(cell)


func _update_cell_color(cell: GridCell) -> void :
	var key: String = cell.color_key()
	var hex: String = ColorManager.COLOR_GLOSSARY.get(key, "#676767")
	cell.this.get_node("GridTexture").modulate = Color.from_string(hex, Color.PURPLE)

func _on_arrow_hovered(alignment: String, index: int) -> void:
	if alignment == "col":
		for row in range(grid_size.y):
			var cell: GridCell = grid[index][row]
			cell.this.get_node("HighlightOverlay").visible = true
	
	elif alignment == "row":
		for col in range(grid_size.x):
			var cell: GridCell = grid[col][index]
			cell.this.get_node("HighlightOverlay").visible = false

func _clear_highlight() -> void:
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var cell: GridCell = grid[col][row]
			cell.this.get_node("HighlightOverlay").visible = false

func _reset_all() -> void :
	for col in range(grid_size.x):
		for row in range(grid_size.y):
			var cell: GridCell = grid[col][row]
			cell.reset()
			_update_cell_color(cell)

func _input(event: InputEvent) -> void :
	if event.is_action_pressed("reset_grid"):
		_reset_all()
		SaveStatesManager.reset()
