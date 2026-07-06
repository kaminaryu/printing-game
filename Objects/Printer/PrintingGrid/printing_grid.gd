extends Node2D

@export var grid_size: Vector2 = Vector2(5, 5)

@onready var square_scene = preload("res://Objects/Printer/PrintingGrid/grid_square.tscn")
@onready var line_picker_scene = preload("res://Objects/Printer/PrintingGrid/line_picker.tscn")


const GRID_SQUARE_SIZE: int = 32
const CELL_GAP: int = 2
const BUTTON_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000"]


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

		return true # fallabck


	func apply_ink(channel: String) -> void :
		var is_allowed: bool = _same_color_safeguard(channel)
		if (!is_allowed) :
			return

		match channel :
			"c": c += 1
			"m": m += 1
			"y": y += 1
			_: printerr("Unknown ink channel: %s" % channel)


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
		c = 0
		m = 0
		y = 0
		toggle_ink_lock(false)
		saved_color = {"0": "000"}
		saved_lock = {"0": false}


var grid: Array = []


func _ready() -> void :
	_init_grid()
	_init_buttons()
	SaveStatesManager.grid_redraw_request.connect(_set_cell_state)


func _init_grid() -> void :
	for col in range(grid_size.x):
		var columns: Array = []

		for row in range(grid_size.y):
			var cell_node: Node2D = square_scene.instantiate()

			cell_node.position = Vector2(col, row) * (GRID_SQUARE_SIZE + CELL_GAP)
			add_child(cell_node)
			columns.append(GridCell.new(cell_node))

		grid.append(columns)


func _init_buttons() -> void :
	const MARGIN: float = 4.0;
	# column button
	for col in range(grid_size.x):
		var arrow: Node = line_picker_scene.instantiate()
		
		arrow.position = Vector2(
			col * (GRID_SQUARE_SIZE + CELL_GAP) - 8,
			-(GRID_SQUARE_SIZE + MARGIN),
		)
		arrow.grid_alignment = "col"
		arrow.grid_index = col
		arrow.paint_requested.connect(_on_paint_request)

		add_child(arrow)


	# row buttons
	for row in range(grid_size.y):
		var arrow: Node = line_picker_scene.instantiate()
		
		arrow.position = Vector2(
			-(GRID_SQUARE_SIZE + MARGIN),
			row * (GRID_SQUARE_SIZE + CELL_GAP) + 8,
		)
		arrow.grid_alignment = "row"
		arrow.grid_index = row
		arrow.rotation = -PI/2
		arrow.paint_requested.connect(_on_paint_request)

		add_child(arrow)


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
	# iterate over all row in the column
	for row in range(grid_size.y):
		var cell: GridCell = grid[col][row]

		# if channel = K, toggle lock
		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		# if the grid is ink locked, dont draw
		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		cell.apply_ink(channel)
		_update_cell_color(cell)

	var locked: bool = (lock_cell_count == grid_size.y)
	return locked


func _paint_row(row: int, channel: String) -> bool :
	var lock_cell_count: int = 0
	# iterate over all column in the row
	for col in range(grid_size.x):
		var cell: GridCell = grid[col][row]
		
		# if channel = K, toggle lock
		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock()
			continue

		# if the grid is ink locked, dont draw
		if (cell.is_ink_locked()) :
			lock_cell_count += 1
			continue

		cell.apply_ink(channel)
		_update_cell_color(cell)

	var locked: bool = (lock_cell_count == grid_size.x)
	return locked


func _save_current_state() -> void :
	# none zero
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
	var hex: String = ColorManager.COLOR_GLOSSARY.get(key, "#000000")

	cell.this.get_node("GridTexture").modulate = Color.from_string(hex, Color.PURPLE)


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
