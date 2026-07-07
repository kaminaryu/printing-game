extends Control 

@export var max_boundary_size: float = 128.0

@export var cell_gap: float = 1.0

func update_preview(level_data: LevelData) -> void:
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
		(max_boundary_size - total_grid_width) / 2.0,
		(max_boundary_size - total_grid_height) / 2.0
	)

	var grid_2d: Array = level_data.get_target_grid_2d()
	
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
