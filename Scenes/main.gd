extends Node2D

var current_level: LevelData

@onready var printing_grid = $PrintingGrid
@onready var grid_animator = $GridAnimator
@onready var target_preview_grid = $CanvasLayer/TargetGrid
@onready var victory_grid = $CanvasLayer/VictoryPanel/VictoryTarget
@onready var victory_animation = $CanvasLayer/VictoryPanel/AnimationPlayer
@onready var blur_panel = $"CanvasLayer/Blur Panel"
@onready var ink_cartridges = $Cartridges

@onready var level_win = $LevelWin
@onready var level_start = $LevelStart

@onready var main_gui = $CanvasLayer/MainGUI
@onready var paper_guide = $CanvasLayer/PaperGuide
@onready var timer_label = $CanvasLayer/Timer
@onready var level_title = $"CanvasLayer/Level Title"
@onready var time_elapsed_label = $CanvasLayer/VictoryPanel/Time
# Safety gate to prevent rapid multiple level loads
var is_transitioning: bool = false

var target_grid_data: Array = []
var remaining_ink: Dictionary = {}
var _starting_ink: Dictionary = {} 

var timer_running: bool
var elapsed_time := 0.0

signal ink_inventory_updated(channel: String, remaining_count: int)

func _ready() -> void:
	printing_grid.paint_cascade_finished.connect(_on_grid_updated)
	ink_inventory_updated.connect(ink_cartridges.update_ink_label)
	var _load_level_by_number_successful: bool = _load_level_by_number(GameMaster.current_level_num)


func _process(delta):
	if timer_running:
		elapsed_time += delta
		timer_label.text = format_time(elapsed_time)


func _load_level(level_data: LevelData) -> void:
	reset_timer()
	level_title.text = level_data.level_name
	level_title.play_animation()
	timer_running = true
	main_gui.visible = true
	paper_guide.visible = true
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
	
	for channel in remaining_ink.keys():
		ink_inventory_updated.emit(channel, remaining_ink[channel])


func _load_level_by_number(level_num: int) -> bool:
	var path: String = "res://Resources/Levels/%d.tres" % level_num
	
	if ResourceLoader.exists(path):
		var loaded_resource = load(path) as LevelData
		if loaded_resource:
			SaveStatesManager.reset() 
			ink_cartridges.update_visible_channels(loaded_resource)
			_load_level(loaded_resource)
			
			is_transitioning = false
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
	if is_transitioning:
		return

	if check_victory_condition():
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
	timer_running = false

	time_elapsed_label.text = format_time_ms(elapsed_time) 

	await get_tree().create_timer(0.5).timeout
	grid_animator.play("Level End")

	level_win.pitch_scale = randf_range(0.9, 1.1)
	level_win.play()
	await grid_animator.animation_finished

	main_gui.visible = false
	paper_guide.visible = false
	blur_panel.visible = true

	GameMaster.save_level_data(elapsed_time)
	
	if victory_animation:
		victory_animation.play("Print In")



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

func format_time(time: float) -> String:
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	return "%02d:%02d" % [minutes, seconds]

func format_time_ms(time: float) -> String:
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func reset_timer():
	elapsed_time = 0

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

	#if event.is_action_pressed("select_cyan"):
		#ColorManager.selected_color = 0
	#elif event.is_action_pressed("select_magenta"):
		#ColorManager.selected_color = 1
	#elif event.is_action_pressed("select_yellow"):
		#ColorManager.selected_color = 2
	#elif event.is_action_pressed("select_key"):
		#ColorManager.selected_color = 3
	#CursorManager.set_cursor()
