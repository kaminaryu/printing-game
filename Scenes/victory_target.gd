extends Control 

@export var max_boundary_size: float = 128.0
@export var cell_gap: float = 1.0

# 🎨 1. Load your single, default texture assets here once
@onready var DEFAULT_MAIN_TEXTURE = preload("res://Assets/game/Cell/cell_inside.png")
@onready var DEFAULT_OVERLAY_TEXTURE = preload("res://Assets/game/Cell/cell_overlay.png")

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
			var target_key: String = grid_2d[col][row]
			
			# 🎯 2. Create the parent 'GridCell' Control node
			var cell_container: Control = Control.new()
			cell_container.name = "GridCell"
			cell_container.size = pixel_size
			
			var pos_x: float = offset.x + (col * (calculated_block_size + cell_gap))
			var pos_y: float = offset.y + (row * (calculated_block_size + cell_gap))
			cell_container.position = Vector2(pos_x, pos_y)
			
			# 🎯 3. Create the 'GridTexture' (Main Background using your 1 default)
			var grid_texture: TextureRect = TextureRect.new()
			grid_texture.name = "GridTexture"
			grid_texture.texture = DEFAULT_MAIN_TEXTURE
			grid_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			grid_texture.stretch_mode = TextureRect.STRETCH_SCALE
			grid_texture.size = pixel_size
			
			# Modulate this single default texture dynamically using your color glossary
			var hex: String = ColorManager.COLOR_GLOSSARY.get(target_key, "#676767")
			grid_texture.modulate = Color.from_string(hex, Color.PURPLE)
			
			# 🎯 4. Create the 'TextureOverlay' (The Face/Outline using your 1 default)
			var texture_overlay: TextureRect = TextureRect.new()
			texture_overlay.name = "TextureOverlay"
			texture_overlay.texture = DEFAULT_OVERLAY_TEXTURE
			texture_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_overlay.stretch_mode = TextureRect.STRETCH_SCALE
			texture_overlay.size = pixel_size
			
			# Keep the overlay untinted so it retains its pure default look
			texture_overlay.modulate = Color.WHITE 
			
			# 🎯 5. Assemble the hierarchy to mirror your exact layout structure
			cell_container.add_child(texture_overlay)  # Added first so it stacks beautifully
			cell_container.add_child(grid_texture)    # Stacks right alongside it
			
			# Push GridTexture to index 0 so it renders physically behind the overlay layer
			cell_container.move_child(grid_texture, 0) 
			
			add_child(cell_container)
