# level_data.gd
extends Resource
class_name LevelData

@export_subgroup("Grid Configuration")
@export var grid_size: Vector2i = Vector2i(5, 5)

@export_subgroup("Solution Layout")
@export var target_colors: Array[String] = []

func get_target_grid_2d() -> Array:
	var grid_2d: Array = []
	
	for col in range(grid_size.x):
		grid_2d.append([])
	
	var index: int = 0
	for row in range(grid_size.y):
		for col in range(grid_size.x):
			if index < target_colors.size():
				grid_2d[col].append(target_colors[index])
			else:
				grid_2d[col].append("000")
			index += 1
			
	return grid_2d
