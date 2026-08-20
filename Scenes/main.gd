extends Node2D

var current_level_data: LevelData

@onready var printing_canvas = $PrintingCanvas
@onready var grid_animator = $GridAnimator
@onready var preview_grid = $CanvasLayer/PreviewGrid

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

@onready var time_elapsed_label = $CanvasLayer/VictoryPanel/TimeInfo/TimeElapsed/Time
@onready var current_best_title = $CanvasLayer/VictoryPanel/TimeInfo/CurrentBest/Title
@onready var current_best_label = $CanvasLayer/VictoryPanel/TimeInfo/CurrentBest/Time
@onready var current_best_container = $CanvasLayer/VictoryPanel/TimeInfo/CurrentBest

@onready var congrats_panel = $CanvasLayer/CongratsPanel
@onready var congrats_panel_animation = $CanvasLayer/CongratsPanel/AnimationPlayer

@onready var current_level_counter_label = $CanvasLayer/LevelCounterContainer/CurrentLevel
@onready var total_level_counter_label = $CanvasLayer/LevelCounterContainer/TotalLevel

@onready var tutorials := $CanvasLayer/Tutorials


# Safety gate to prevent rapid multiple level loads
var is_transitioning: bool = false

var target_grid_data: Array[Array] = []
var remaining_ink: Dictionary = {}
var _starting_ink: Dictionary = {}

var game_in_progress: bool
var elapsed_time := 0.0

# when an ink is used
signal ink_inventory_updated(channel: String, remaining_count: int)

func _ready() -> void:
	printing_canvas.paint_cascade_finished.connect(_on_grid_updated)
	ink_inventory_updated.connect(ink_cartridges.update_ink_label)
	tutorials.tutorial_finished.connect(_on_tutorial_finished)

	var _load_level_by_number_successful: bool = _load_level_by_number(GameMaster.current_level_num)
	CursorManager.set_cursor()


func _process(delta):
	if game_in_progress:
		elapsed_time += delta
		timer_label.text = format_time(elapsed_time)


func _load_level(level_data: LevelData) -> void:
	# if the level is the 1st level (which have tutorial), do not run game yet
	if (GameMaster.current_level_num != 1) :
		game_in_progress = true
		
	GameMaster.is_printing_completed = false
	reset_timer()
	level_title.text = level_data.level_name
	level_title.play_animation()
	main_gui.visible = true
	paper_guide.visible = true
	current_level_data = level_data
	target_grid_data = level_data.get_target_grid_2d()
	
	remaining_ink = level_data.ink_limits.duplicate()
	_starting_ink = level_data.ink_limits.duplicate()
	
	printing_canvas.setup_and_build(level_data.grid_size)
	printing_canvas.change_paper_color(level_data.paper_color)
	
	level_start.pitch_scale = randf_range(0.9, 1.1)
	level_start.play()
	grid_animator.play("Level Start")
	
	for channel in remaining_ink.keys():
		ink_inventory_updated.emit(channel, remaining_ink[channel])


func _load_level_by_number(level_num: int) -> bool:
	var level_data: LevelData = GameMaster.fetch_level_data(level_num)

	if level_data :
		SaveStatesManager.reset() 
		ink_cartridges.update_visible_channels(level_data)

		preview_grid.generate_preview(level_num)
		victory_grid.generate_preview(level_num)
		_load_level(level_data)

		_update_level_counter()

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
	if target_grid_data.is_empty() or printing_canvas.canvas_grid.is_empty():
		return false
		
	for col in range(current_level_data.grid_size.x):
		for row in range(current_level_data.grid_size.y):
			var cell: Node = printing_canvas.canvas_grid[col][row]
			if cell.color_key() != target_grid_data[col][row]:
				return false
	
	return true


func _handle_level_victory() -> void:
	GameMaster.is_printing_completed = true

	is_transitioning = true
	game_in_progress = false

	time_elapsed_label.text = format_time_ms(elapsed_time) 

	await get_tree().create_timer(0.5).timeout
	grid_animator.play("Level End")

	level_win.pitch_scale = randf_range(0.9, 1.1)
	level_win.play()
	await grid_animator.animation_finished

	main_gui.visible = false
	paper_guide.visible = false
	blur_panel.visible = true

	var completion_data: Dictionary = GameMaster.load_level_completion_data()

	# if its a new completion
	if (completion_data.is_empty()) :
		current_best_label.text = format_time_ms(elapsed_time)
		current_best_container.hide()
	# if its a new best
	elif (elapsed_time < completion_data["best_time"]) :
		current_best_title.text = "New Best!"
		current_best_title.label_settings.font_color    = Color("#E5B400")
		current_best_title.label_settings.outline_color = Color("#E5B400")
		current_best_label.text = format_time_ms(elapsed_time)
		current_best_container.show()
		
	else :
		current_best_title.text = "Best Time"
		current_best_title.label_settings.font_color    = Color("#000000")
		current_best_title.label_settings.outline_color = Color("#000000")
		current_best_label.text = format_time_ms(completion_data["best_time"] )
		current_best_container.show()

	GameMaster.save_level_completion_data(elapsed_time)
	
	if victory_animation:
		victory_animation.play("Print In")


func reset_entire_level() -> void:
	SaveStatesManager.reset()
	
	remaining_ink = _starting_ink.duplicate()
	for channel in remaining_ink.keys():
		ink_inventory_updated.emit(channel, remaining_ink[channel])
			
	printing_canvas.reset_grid_visuals(current_level_data)


func _update_level_counter() -> void :
	current_level_counter_label.text = str(GameMaster.current_level_num)

	total_level_counter_label.text   = str(GameMaster.level_count)


func _on_continue_button_pressed() -> void:
	victory_animation.play("Print Out")
	await victory_animation.animation_finished
	
	if(GameMaster.current_level_num >= GameMaster.level_count):
		level_win.play()
		congrats_panel_animation.play("Complete_In")
	else:
		blur_panel.visible = false
		GameMaster.increase_level()
		_load_level_by_number(GameMaster.current_level_num)


func format_time(time_s: float) -> String:
	@warning_ignore("INTEGER_DIVISION")
	var minutes = int(time_s) / 60
	var seconds = int(time_s) % 60

	const one_hour_in_seconds = 3600

	if (time_s < one_hour_in_seconds) :
		return "%02d:%02d" % [minutes, seconds]

	@warning_ignore("INTEGER_DIVISION")
	var hours = minutes / 60
	minutes %= 60
	return "%d:%02d:%02d" % [hours, minutes, seconds]


func format_time_ms(time_s: float) -> String:
	@warning_ignore("INTEGER_DIVISION")
	var minutes = int(time_s) / 60
	var seconds = int(time_s) % 60
	var milliseconds = int((time_s - int(time_s)) * 100) # get the decimals
	const one_hour_in_seconds = 3600

	if (time_s < one_hour_in_seconds) :
		return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

	@warning_ignore("INTEGER_DIVISION")
	var hours = minutes / 60
	minutes %= 60
	return "%d:%02d:%02d.%02d" % [hours, minutes, seconds, milliseconds]


func reset_timer():
	elapsed_time = 0


func _on_tutorial_finished() -> void :
	game_in_progress = true


func _input(event: InputEvent) -> void :
	if printing_canvas.is_cascading or not game_in_progress :
		return
	
	if event.is_action_pressed("undo") :
		SaveStatesManager.undo_action()

	elif event.is_action_pressed("redo") :
		SaveStatesManager.redo_action()
		
	elif event.is_action_pressed("reset_grid") :
		reset_entire_level()


	if event.is_action_pressed("select_cyan"):
		if ("c" in current_level_data.available_channels) :
			ColorManager.selected_color = 0

	elif event.is_action_pressed("select_magenta"):
		if ("m" in current_level_data.available_channels) :
			ColorManager.selected_color = 1

	elif event.is_action_pressed("select_yellow"):
		if ("y" in current_level_data.available_channels) :
			ColorManager.selected_color = 2

	elif event.is_action_pressed("select_key"):
		if ("k" in current_level_data.available_channels) :
			ColorManager.selected_color = 3
