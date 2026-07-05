extends Node2D

@onready var GRID_SQUARE_SCENE = preload("res://Objects/Printer/PrintingGrid/grid_square.tscn")
@onready var COLOR_NODE_SCENE = preload("res://Objects/Printer/PrintingGrid/color_node_better.tscn")

@export var grid_size: Vector2

const GRID_SQUARE_SIZE: int = 32

var grid_squares := []
var color_nodes := {
	"col": [],
	"row": [],
}


func _ready() -> void :
	grid_squares.resize(grid_size.x)

	for col in range(grid_size.x) :
		grid_squares[col] = []
		grid_squares[col].resize(grid_size.y)
		
		# instantiate color node for column
		color_nodes.col.resize(grid_size.x)
		color_nodes.col[col] = COLOR_NODE_SCENE.instantiate()
		color_nodes.col[col].position = global_position + Vector2(col * GRID_SQUARE_SIZE , -GRID_SQUARE_SIZE - 2)
		color_nodes.col[col].grid_alignment = "col"
		color_nodes.col[col].grid_index = col
		color_nodes.col[col].print_button_pressed.connect(_paint)
		add_child(color_nodes.col[col])

		# instantiate row of grid
		for row in range(grid_size.y) :
			# instantiate color node for row
			color_nodes.row.resize(grid_size.x)
			color_nodes.row[row] = COLOR_NODE_SCENE.instantiate()
			color_nodes.row[row].position = global_position + Vector2(-GRID_SQUARE_SIZE - 2, row * GRID_SQUARE_SIZE)
			color_nodes.row[row].grid_alignment = "row"
			color_nodes.row[row].grid_index = row
			color_nodes.row[row].print_button_pressed.connect(_paint)
			add_child(color_nodes.row[row])

			
			grid_squares[col][row] = GRID_SQUARE_SCENE.instantiate()
			grid_squares[col][row].position = global_position + Vector2(col, row) * (GRID_SQUARE_SIZE + 2)
			add_child(grid_squares[col][row])




func _input(event: InputEvent) -> void :
	if (event.is_action_pressed("refresh_grid")) :
		_paint({})


func _paint(print_request: Dictionary):
	var grid_alignmnet: String = print_request.get("grid_alignment")
	var grid_index: int        = print_request.get("grid_index")
		
	if (grid_alignmnet == "row") :
		for c in range(grid_size.y) :
			grid_squares[c][grid_index].modulate.r -= 0.1

	elif (grid_alignmnet == "col") :
		for r in range(grid_size.x) :
			grid_squares[grid_index][r].modulate.r -= 0.1

	else :
		printerr("ERROR WHEN PAINTING: Set row/col pls")
