extends Node2D

const GRID_CELL_SCENE: PackedScene = preload("res://Objects/Printer/PrintingGrid/grid_cell.tscn")
const MAX_GRID_BOUNDS: float = 350.0
const CELL_GAP: int = 2

@export var paper_sprite: Sprite2D
@export var grid: Node2D
@export var max_canvas_size := Vector2i()

var canvas_grid: Array[Array]
var _selected_color_key: String = "000"


func draw_grid(canvas_grid_size: Vector2i) -> void :
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
			
			cell_node.scale = target_scale
			cell_node.is_paper_editor_mode = true
			cell_node.set_color_key(_selected_color_key) # NOTE: For resizing
			grid.add_child(cell_node)
			columns.append(cell_node)

		canvas_grid.append(columns)


func change_paper_color(color_key: String) -> void :
	# save the selected color_key for resizing to refresh the grid
	_selected_color_key = color_key

	# repaint the whole grid with this color
	for cell in grid.get_children() :
		cell.set_color_key(color_key)

	paper_sprite.modulate = Color(ColorManager.COLOR_GLOSSARY[color_key])


func get_paper_color() -> String :
	return "#%s" % paper_sprite.modulate.to_html(false)
