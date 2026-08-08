extends Node2D

const GRID_CELL_SCENE: PackedScene = preload("res://Objects/Printer/PrintingGrid/grid_cell.tscn")
const MAX_GRID_BOUNDS: float = 350.0
const CELL_GAP: int = 2

@export var paper_sprite: Sprite2D
@export var grid: Node2D

var canvas_grid: Array[Array]
var _selected_paper_color_key: String = "000"


# NOTE: For changing individual cell color is done by the cells themselves


func draw_grid(canvas_grid_size: Vector2i, is_cloning_grid := false) -> void :
	var previous_canvas_grid : Array[Array]

	# for repainting the grid when it resizes during paper setup
	## to preserve the previous canvas
	if (is_cloning_grid) :
		previous_canvas_grid = canvas_grid.duplicate()

	# delete existing cell inside the grid
	for cell in grid.get_children() :
		cell.queue_free()
	
	# calc largest axis count
	var max_axis_count: float = max(canvas_grid_size.x, canvas_grid_size.y)
	# check avaiable space in the paper to draw the grid
	var available_space: float = MAX_GRID_BOUNDS - ((max_axis_count - 1.0) * CELL_GAP)
	# for scaling grid size dynamically
	var dynamic_cell_size = floor(available_space / max_axis_count)
	# add gaps between cells
	var cell_with_padding_size = dynamic_cell_size + CELL_GAP

	var total_grid_size: Vector2 = canvas_grid_size * cell_with_padding_size - Vector2(CELL_GAP, CELL_GAP)
	var center_offset = ( -(total_grid_size / 2.0) + (Vector2.ONE * (dynamic_cell_size / 2.0)) ).floor()

	canvas_grid = []

	for col in range(canvas_grid_size.x):
		var columns: Array = []

		for row in range(canvas_grid_size.y):
			var cell_node: Node2D = GRID_CELL_SCENE.instantiate()
			var cell_pos: Vector2 = (Vector2(col, row) * cell_with_padding_size) + center_offset
			cell_node.position = cell_pos.floor()
			
			var sprite: Sprite2D = cell_node.get_node("GridTexture") as Sprite2D
			var target_scale: Vector2 = Vector2.ONE
			
			if sprite and sprite.texture:
				var original_size: Vector2 = sprite.texture.get_size()
				target_scale = (Vector2.ONE * dynamic_cell_size) / original_size
			
			# for repainting the grid when resizing the grid
			if (is_cloning_grid) :
				# if the current coords has a previous version
				if (col < previous_canvas_grid.size() and row < previous_canvas_grid[0].size()) :
					var previous_cell_node: GridCell = previous_canvas_grid[col][row]
					cell_node.set_color_key(previous_cell_node.color_key())
					cell_node.toggle_ink_lock(previous_cell_node.is_ink_locked())
				else :
					cell_node.set_color_key(_selected_paper_color_key)


			cell_node.scale = target_scale
			cell_node.is_paper_editor_mode = true
			cell_node.coords = Vector2i(col, row)
			grid.add_child(cell_node)
			columns.append(cell_node)

		canvas_grid.append(columns)


func change_paper_color(color_key: String) -> void :
	# save the selected color_key for resizing to refresh the grid
	_selected_paper_color_key = color_key

	# repaint the whole grid with this color
	for cell in grid.get_children() :
		cell.set_color_key(color_key)

	paper_sprite.modulate = Color(ColorManager.COLOR_GLOSSARY[color_key])


func get_paper_color() -> String :
	return "#%s" % paper_sprite.modulate.to_html(false)


# -- for resizing grid history management --
func get_row_line_cells(index: int) -> Array[String] :
	var cells: Array[String]

	for i in canvas_grid :
		for j in i :
			print(j.get_cmyk())

	for i in range(canvas_grid.size()) :
		cells.append(canvas_grid[i][index].get_cmyk())

	return cells


func get_col_line_cells(index: int) -> Array[String] :
	var cells: Array[String]

	for i in range(canvas_grid[index].size()) :
		cells.append(canvas_grid[index][i].get_cmyk())

	return cells


func paint_row(index: int, line_cells_data: Array[String]) -> void :
	print("Printing Row ", line_cells_data)
	for i in range(canvas_grid.size()) :
		var cell: GridCell = canvas_grid[i][index]
		cell.set_color_key(line_cells_data[i].substr(0, 3))
		cell.toggle_ink_lock(true if line_cells_data[i][-1] == "1" else false)



func paint_col(index: int, line_cells_data: Array[String]) -> void :
	print("Printing Not Row ", line_cells_data)
	for i in range(canvas_grid[index].size()) :
		var cell: GridCell = canvas_grid[index][i]
		cell.set_color_key(line_cells_data[i].substr(0, 3))
		cell.toggle_ink_lock(true if line_cells_data[i][-1] == "1" else false)


# -- for clearing and redrawing cleared grid -- 
func paint_whole_grid(p_canvas_grid_cmyk: Array[Array]) :
	for col in range(p_canvas_grid_cmyk.size()) :
		for row in range(p_canvas_grid_cmyk[col].size()) :
			var cell: GridCell = canvas_grid[col][row]
			var cell_cmyk: String = p_canvas_grid_cmyk[col][row]

			cell.set_color_key(cell_cmyk.substr(0, 3))
			cell.toggle_ink_lock(true if cell_cmyk[-1] == "1" else false)
