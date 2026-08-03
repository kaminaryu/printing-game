extends Control 

@export var max_boundary_size: float = 175.0

@export var cell_gap: float = 3.0

func generate_preview(level_num: int) -> void :
	var path: String = "res://Resources/Levels/%d.tres" % level_num
	
	if ResourceLoader.exists(path):
		var level_data = load(path) as LevelData
		_draw_grid(level_data)
		return

	# if level doesnt exist, open up the blank canvas
	path = "res://Resources/blank_canvas.tres"
	
	if ResourceLoader.exists(path) :
		var level_data = load(path) as LevelData
		_draw_grid(level_data)



func _draw_grid(level_data: LevelData) -> void:
	for child in get_children():
		child.queue_free()
		
	var grid_x: int = level_data.grid_size.x
	var grid_y: int = level_data.grid_size.y

	var max_dimension: int = max(grid_x, grid_y)
	
	var total_gap_space: float = cell_gap * (max_dimension - 1)
	
	var calculated_block_size: float = (max_boundary_size - total_gap_space) / max_dimension
	var pixel_size: Vector2 = Vector2(calculated_block_size, calculated_block_size)
	
	var total_grid_width: float = (grid_x * calculated_block_size) + ((grid_x - 1) * cell_gap)
	var total_grid_height: float = (grid_y * calculated_block_size) + ((grid_y - 1) * cell_gap)
	var offset: Vector2 = Vector2(
		-total_grid_width / 2.0,
		-total_grid_height / 2.0
	)

	var grid_2d: Array[Array] = level_data.get_target_grid_2d()
	
	for row in range(grid_y):
		for col in range(grid_x):
			var pixel: ColorRect = ColorRect.new()
			
			pixel.size = pixel_size
			
			var pos_x: float = offset.x + (col * (calculated_block_size + cell_gap))
			var pos_y: float = offset.y + (row * (calculated_block_size + cell_gap))
			pixel.position = Vector2(pos_x, pos_y)
			
			var target_key: String = grid_2d[col][row]
			var hex: String = ColorManager.COLOR_GLOSSARY.get(target_key, "#676767")
			pixel.color = Color.from_string(hex, Color.PURPLE)
			
			add_child(pixel)
