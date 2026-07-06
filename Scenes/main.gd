extends Node2D

@export var current_level: LevelData

@onready var printing_grid = $PrintingGrid
@onready var target_preview_grid = $CanvasLayer/TargetGrid

var target_grid_data: Array = []


func _ready() -> void:
	printing_grid.paint_cascade_finished.connect(_on_grid_updated)
	if(current_level):
		load_level(current_level)
		
func load_level(level_data: LevelData) -> void:
	current_level = level_data
	target_grid_data = level_data.get_target_grid_2d()
	
	# 1. Direct the UI component to draw itself
	target_preview_grid.update_preview(level_data)
	
	printing_grid.setup_and_build(level_data.grid_size)

func _on_grid_updated() -> void:
	if check_victory_condition():
		_handle_level_victory()
		
func check_victory_condition() -> bool:
	if target_grid_data.is_empty() or printing_grid.grid.is_empty():
		return false
		
	for col in range(current_level.grid_size.x):
		for row in range(current_level.grid_size.y):
			var cell: Node = printing_grid.grid[col][row]
			if cell.color_key() != target_grid_data[col][row]:
				return false
				
	return true
	
func _handle_level_victory() -> void:
	print("Level Cleared! Advancing game state...")

func _input(event: InputEvent) -> void :
	if (event.is_action_pressed("undo")) :
		SaveStatesManager.undo_action()

	elif (event.is_action_pressed("redo")) :
		SaveStatesManager.redo_action()
