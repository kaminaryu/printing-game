extends Node2D

# @export var current_level: LevelData
var current_level: LevelData

@onready var printing_grid = $PrintingGrid
@onready var grid_animator = $GridAnimator
@onready var target_preview_grid = $CanvasLayer/TargetGrid
@onready var victory_grid = $CanvasLayer/VictoryPanel/VictoryTarget
@onready var palette = $CanvasLayer/Palette
@onready var victory_animation = $CanvasLayer/VictoryPanel/AnimationPlayer
@onready var blur_panel = $"CanvasLayer/Blur Panel"

@onready var level_win = $LevelWin
@onready var level_start = $LevelStart
# Safety gate to prevent rapid multiple level loads
var is_transitioning: bool = false

var target_grid_data: Array = []
var remaining_ink: Dictionary = {}
var _starting_ink: Dictionary = {} 

signal ink_inventory_updated(channel: String, remaining_count: int)

func _ready() -> void:
	printing_grid.paint_cascade_finished.connect(_on_grid_updated)
	
	# Try loading the numeric level sequence first. 
	# If no dynamic file is found, fallback to whatever is manually assigned in the inspector slot.
	
	var _load_level_by_number_successful: bool = _load_level_by_number(GameMaster.current_level_num)

	# if not _load_level_by_number_successful and current_level:
	# 	_load_level(current_level)


func _load_level(level_data: LevelData) -> void:
	current_level = level_data
	target_grid_data = level_data.get_target_grid_2d()
	
	remaining_ink = level_data.ink_limits.duplicate()
	_starting_ink = level_data.ink_limits.duplicate()
	
	target_preview_grid.update_preview(level_data)
	victory_grid.update_preview(level_data)
	printing_grid.setup_and_build(level_data.grid_size)
	
	level_start.pitch_scale = randf_range(0.9, 1.1)
	level_start.play()
	grid_animator.play("Level Start")

	palette.update_visible_channels(level_data)

	for channel in remaining_ink.keys():
		ink_inventory_updated.emit(channel, remaining_ink[channel])


## Helper to safely format paths, check if the resource file exists, and run setup
func _load_level_by_number(level_num: int) -> bool:
	var path: String = "res://Resources/Levels/%d.tres" % level_num
	
	if ResourceLoader.exists(path):
		var loaded_resource = load(path) as LevelData
		if loaded_resource:
			# Safely reset global undo/redo states before building the new map
			SaveStatesManager.reset() 
			
			_load_level(loaded_resource)
			
			# Reset our gate state since a fresh new map is ready for inputs
			is_transitioning = false
			
			print("🎮 Successfully loaded Level ", level_num)
			return true
			
	return false


func use_ink_channel(channel: String) -> bool:
	if not remaining_ink.has(channel) or remaining_ink[channel] == -1:
		return true
		
	if remaining_ink[channel] <= 0:
		print("Click Blocked: Out of ink for channel: ", channel)
		return false
		
	remaining_ink[channel] -= 1
	ink_inventory_updated.emit(channel, remaining_ink[channel])
	return true


func _on_grid_updated() -> void:
	# Slam the door shut if a level update signal comes in mid-transition
	if is_transitioning:
		return

	if check_victory_condition():
		# Lock the gate instantly so no more checks can sneak past
		is_transitioning = true
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
	is_transitioning = true
	await get_tree().create_timer(0.5).timeout
	grid_animator.play("Level End")
	level_win.pitch_scale = randf_range(0.9, 1.1)
	level_win.play()
	await grid_animator.animation_finished
	blur_panel.visible = true
	
	if victory_animation:
		victory_animation.play("Print In")

	# GameMaster.increase_level()
	#_load_level_by_number(GameMaster.current_level_num)
	


func reset_entire_level() -> void:
	SaveStatesManager.reset()
	
	remaining_ink = _starting_ink.duplicate()
	for channel in remaining_ink.keys():
		ink_inventory_updated.emit(channel, remaining_ink[channel])
			
	if printing_grid and printing_grid.has_method("reset_grid_visuals"):
		printing_grid.reset_grid_visuals()


func _on_continue_button_pressed() -> void:
	victory_animation.play("Print Out")
	await victory_animation.animation_finished
	blur_panel.visible = false
	
	
	GameMaster.increase_level()
	_load_level_by_number(GameMaster.current_level_num)


func _input(event: InputEvent) -> void :
	if printing_grid.is_cascading:
		return
	
	if event.is_action_pressed("undo") :
		SaveStatesManager.undo_action()

	elif event.is_action_pressed("redo") :
		SaveStatesManager.redo_action()
		
	elif event.is_action_pressed("reset_grid") :
		reset_entire_level()

	#elif event.is_action_pressed("escape") :
	#	pass
