extends Control

@export var printing_canvas: Node2D
@export var menu: Control
@export var settings: Control
@export var ink_counter: HBoxContainer


func _ready() -> void :
	load_level_data(1)
	printing_canvas.ink_used_in_editor.connect(_increase_amount_of_ink_used)


###########
# Actions #
###########
func load_level_data(level_num: int) -> void :
	var path: String = "res://Resources/Levels/%d.tres" % level_num
	
	if ResourceLoader.exists(path):
		var level_data = load(path) as LevelData

		if level_data :
			SaveStatesManager.reset()
			LevelHistoryManager.init_level_history(level_data)

			_set_level_metadata_to_editor(level_data) # MUST set metadata first or else resize_grid signal will be emitted
			_load_ink_counter(level_data)
			_draw_level_to_canvas(level_data)
			return

	# if level doesnt exist, open up the blank canvas
	path = "res://Resources/blank_canvas.tres"
	
	if ResourceLoader.exists(path) :
		var level_data = load(path) as LevelData

		if level_data :
			SaveStatesManager.reset()
			LevelHistoryManager.init_level_history(level_data)

			_set_level_metadata_to_editor(level_data)
			_load_ink_counter(level_data)
			_draw_level_to_canvas(level_data)



func _draw_level_to_canvas(level_data: LevelData) -> void :
	printing_canvas.setup_and_build(level_data.grid_size)

	var color_keys: Array[Array] = level_data.get_target_grid_2d()
	printing_canvas.paint_canvas(color_keys)


func _set_level_metadata_to_editor(level_data: LevelData) -> void :
	settings.load_level_metadata(level_data)


func redraw_grid_canvas(new_grid_size: Vector2i) -> void:
	printing_canvas.setup_and_build(new_grid_size)
	# LevelHistoryManager.


# -- Ink Counter Related Issues --
func _increase_amount_of_ink_used(color_channel: String) -> void :
	var counter: Label

	match color_channel :
		"c": 
			counter = ink_counter.get_node("Cyan/Label")
		"m": 
			counter = ink_counter.get_node("Magenta/Label")
		"y": 
			counter = ink_counter.get_node("Yellow/Label")
		"k": 
			counter = ink_counter.get_node("Key/Label")

	counter.text = str(int(counter.text) + 1)


func get_ink_counter() -> Array[int] :
	var ink_used: Array[int] = []

	for counter in ink_counter.get_children() :
		if not (counter is PanelContainer) : continue

		# WARNING: Make sure the Labels are named 'Label' and are in CMYK order
		var amount: int = int(counter.get_node("Label").text)
		ink_used.append(amount)

	return ink_used


func _load_ink_counter(level_data: LevelData) -> void :
	var index: int = 0

	for counter in ink_counter.get_children() :
		if not (counter is PanelContainer) : continue

		# WARNING: Make sure the Labels are named 'Label' and are in CMYK order
		counter.get_node("Label").text = str(level_data.amount_of_ink_used_cmyk[index])
		index += 1




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
		_on_undo_button_up()
	elif event.is_action_pressed("reset_grid"):
		_on_delete_button_up()


###########
# Signals #
###########
func _on_undo_button_up() -> void:
	var prev_snapshot := LevelHistoryManager.undo_level_edit()

	if (prev_snapshot == null) : return

	printing_canvas.paint_canvas(prev_snapshot.color_keys)
	printing_canvas.lock_canvas(prev_snapshot.lock_states)


func _on_delete_button_up() -> void:
	printing_canvas.reset_grid_visuals()
