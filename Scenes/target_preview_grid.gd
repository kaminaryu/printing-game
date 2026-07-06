# target_preview.gd
extends Control  # Changed from GridContainer to Control for manual sizing freedom

## The maximum bounding box width and height the preview grid is allowed to occupy
@export var max_boundary_size: float = 128.0

## The pixel gap separation between the miniature color squares
@export var cell_gap: float = 1.0

func update_preview(level_data: LevelData) -> void:
	# 1. Clear out old blocks
	for child in get_children():
		child.queue_free()
		
	var grid_x: int = level_data.grid_size.x
	var grid_y: int = level_data.grid_size.y

	# 2. Find the largest dimension to determine our restrictive scaling factor
	var max_dimension: int = max(grid_x, grid_y)
	
	# 3. Calculate total space consumed by gaps along that maximum dimension
	var total_gap_space: float = cell_gap * (max_dimension - 1)
	
	# 4. Math: (Max Boundary Size - Total Gaps) / Total Grid Blocks = Size of 1 Block
	var calculated_block_size: float = (max_boundary_size - total_gap_space) / max_dimension
	var pixel_size: Vector2 = Vector2(calculated_block_size, calculated_block_size)
	
	# 5. Calculate centering offsets if the grid is non-square (e.g. 3x5 or 5x3)
	var total_grid_width: float = (grid_x * calculated_block_size) + ((grid_x - 1) * cell_gap)
	var total_grid_height: float = (grid_y * calculated_block_size) + ((grid_y - 1) * cell_gap)
	var offset: Vector2 = Vector2(
		(max_boundary_size - total_grid_width) / 2.0,
		(max_boundary_size - total_grid_height) / 2.0
	)

	# Fetch the sorted 2D grid matrix data from our level object
	var grid_2d: Array = level_data.get_target_grid_2d()
	
	# 6. Spawn and position the UI ColorRects manually using our math
	for row in range(grid_y):
		for col in range(grid_x):
			var pixel: ColorRect = ColorRect.new()
			
			# Set the precise dynamic size
			pixel.size = pixel_size
			
			# Calculate exact position matching your gameplay PrintingGrid layout math
			var pos_x: float = offset.x + (col * (calculated_block_size + cell_gap))
			var pos_y: float = offset.y + (row * (calculated_block_size + cell_gap))
			pixel.position = Vector2(pos_x, pos_y)
			
			# Assign colors
			var target_key: String = grid_2d[col][row]
			var hex: String = ColorManager.COLOR_GLOSSARY.get(target_key, "#676767")
			pixel.color = Color.from_string(hex, Color.PURPLE)
			
			add_child(pixel)
