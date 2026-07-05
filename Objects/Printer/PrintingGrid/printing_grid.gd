extends Node2D

@export var grid_size: Vector2 = Vector2(5, 5)

@onready var square_scene = preload("res://Objects/Printer/PrintingGrid/grid_square.tscn")
@onready var button_scene = preload("res://Objects/Printer/PrintingGrid/color_node.tscn")


const GRID_SQUARE_SIZE: int = 32
const CELL_GAP: int = 2
const BUTTON_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000"]


class GridCell :
	var this: Node2D
	var ink_locked: bool = false
	var c: int = 0
	var m: int = 0
	var y: int = 0

	func _init(p_node: Node2D) -> void :
		this = p_node

	func apply_ink(channel: String) -> void :
		match channel:
			"c": c += 1
			"m": m += 1
			"y": y += 1
			_:
				printerr("Unknown ink channel: %s" % channel)

	func color_key() -> String :
		return "%d%d%d" % [c, m, y]

	func toggle_ink_lock(lock: bool) -> void :
		ink_locked = lock
		this.get_node("LockIndicator").visible = lock

	func is_ink_locked() -> bool :
		return ink_locked

	func reset() -> void :
		c = 0
		m = 0
		y = 0
		toggle_ink_lock(false)

var grid: Array = []


func _ready() -> void :
	_init_grid()
	_init_buttons()


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
	# column button
	for col in range(grid_size.x):
		for i in ColorManager.CHANNELS.size():
			var btn: TextureButton = button_scene.instantiate()
			btn.position = Vector2(
				col * (GRID_SQUARE_SIZE + CELL_GAP) - 8,
				-(GRID_SQUARE_SIZE + 2) * ((3-i)/2.0 + 1),
			)
			btn.grid_alignment = "col"
			btn.grid_index = col
			btn.ink_channel = ColorManager.CHANNELS[i]
			btn.paint_requested.connect(_on_paint_request)
			btn.modulate = Color.from_string(BUTTON_COLORS[i], "#670067")
			add_child(btn)

	# row buttons
	for row in range(grid_size.y):
		for i in ColorManager.CHANNELS.size():
			var btn: TextureButton = button_scene.instantiate()
			btn.position = Vector2(
				-(GRID_SQUARE_SIZE + 2) * ((3-i)/2.0 + 1),
				row * (GRID_SQUARE_SIZE + CELL_GAP) - 8,
			)
			btn.grid_alignment = "row"
			btn.grid_index = row
			btn.ink_channel = ColorManager.CHANNELS[i]
			btn.paint_requested.connect(_on_paint_request)
			btn.modulate = Color.from_string(BUTTON_COLORS[i], "#670067")
			add_child(btn)


func _on_paint_request(request: Dictionary) -> void :
	var alignment: String = request.get("grid_alignment")
	var index: int        = request.get("grid_index")
	var channel: String   = request.get("ink_channel")

	match alignment:
		"col":
			_paint_column(index, channel)
		"row":
			_paint_row(index, channel)
		_:
			printerr("Unknown grid alignment: %s" % alignment)


func _paint_column(col: int, channel: String) -> void :

	# iterate over all row in the column
	for row in range(grid_size.y):
		var cell: GridCell = grid[col][row] as GridCell

		# if the grid is ink ink locked, dont draw
		if (cell.is_ink_locked()) :
			continue
		
		# if channel = K, lock
		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock(true)
			continue

		cell.apply_ink(channel)
		_update_cell_color(cell)


func _paint_row(row: int, channel: String) -> void :
	# iterate over all column in the row
	for col in range(grid_size.x):
		var cell: GridCell = grid[col][row] as GridCell
		
		# if the grid is ink ink locked, dont draw
		if (cell.is_ink_locked()) :
			continue
		
		# if channel = K, lock
		if (channel == ColorManager.CHANNELS[3]) :
			cell.toggle_ink_lock(true)
			continue

		cell.apply_ink(channel)
		_update_cell_color(cell)


func _update_cell_color(cell: GridCell) -> void :
	var key: String = cell.color_key()
	var hex: String = ColorManager.COLOR_GLOSSARY.get(key, "#000000")

	cell.this.get_node("GridTexture").modulate = Color.from_string(hex, Color.PURPLE)


func _reset_all() -> void :
	for column_variant in grid as Array:
		var column: Array = column_variant as Array

		for cell_variant in column:
			var cell: GridCell = cell_variant as GridCell

			cell.reset()
			_update_cell_color(cell)


func _input(event: InputEvent) -> void :
	if event.is_action_pressed("reset_grid"):
		_reset_all()
