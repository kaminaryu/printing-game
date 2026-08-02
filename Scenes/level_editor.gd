extends Control

@export var printing_canvas: Node2D
@export var menu: Control
@export var settings: Control


func _ready() -> void :
	load_level_data(1)


###########
# Actions #
###########
func load_level_data(level_num: int) -> void :
	var path: String = "res://Resources/Levels/%d.tres" % level_num
	
	if ResourceLoader.exists(path):
		var level_data = load(path) as LevelData

		if level_data :
			SaveStatesManager.reset()
			_draw_level_to_canvas(level_data)
			_set_level_metadata_to_editor(level_data)
			return

	# if level doesnt exist, open up the blank canvas
	path = "res://Resources/blank_canvas.tres"
	
	if ResourceLoader.exists(path) :
		var level_data = load(path) as LevelData

		if level_data :
			SaveStatesManager.reset()
			_draw_level_to_canvas(level_data)
			_set_level_metadata_to_editor(level_data)


func _draw_level_to_canvas(level_data: LevelData) -> void :
	printing_canvas.setup_and_build(level_data.grid_size)
	printing_canvas.paint_existing_level(level_data)


func _set_level_metadata_to_editor(level_data: LevelData) -> void :
	settings.load_level_metadata(level_data)




func redraw_grid_canvas() -> void:
	# Clear paint history
	if has_node("/root/SaveStatesManager"):
		SaveStatesManager.reset()
	


#######################
# Z-Fighting... kinda #
#######################
func put_panel_on_top(priority_panel: Control) -> void :
	# put menu on top
	if (priority_panel == menu) :
		menu.z_index = 1
		settings.z_index = 0
		menu.get_node("MenuBody/Shadow").visible = true
		settings.get_node("Shadow").visible = false
		print("putting menu on top of settings")

	elif (priority_panel == settings) :
		settings.z_index = 1
		menu.z_index = 0
		settings.get_node("Shadow").visible = true
		menu.get_node("MenuBody/Shadow").visible = false
		print("putting settings on top of menu")



# --- History controls ---
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("undo"):
		SaveStatesManager.undo_action()
	elif event.is_action_pressed("redo"):
		SaveStatesManager.redo_action()
	elif event.is_action_pressed("reset_grid"):
		redraw_grid_canvas()
