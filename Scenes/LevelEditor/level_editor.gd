extends Control

@export var printing_canvas: Node2D
@export var menu: Control
@export var settings: Control
@export var ink_counter: HBoxContainer
@export var history_list: VBoxContainer

var level_num: int = 1


const HISTORY_CARD_SCENE: PackedScene = preload("res://UI/LevelEditor/history_card.tscn")


func _ready() -> void :
	printing_canvas.ink_used_in_editor.connect(_increase_amount_of_ink_used)

	LevelHistoryManager.history_added.connect(_on_history_added)
	LevelHistoryManager.history_removed.connect(_on_history_removed)
	LevelHistoryManager.history_cleaned.connect(_on_history_cleaned)

	load_level_data()


###########
# Actions #
###########
func load_level_data() -> void :
	var level_data: LevelData = GameMaster.fetch_level_data(level_num)

	if level_data :
		SaveStatesManager.reset()
		LevelHistoryManager.init_level_history(level_data)

		_set_level_metadata_to_editor(level_data) # MUST set metadata first or else resize_grid signal will be emitted
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


func _set_ink_counter(new_ink_counter: Array[int]) -> void :
	var index: int = 0

	for counter in ink_counter.get_children() :
		if not (counter is PanelContainer) : continue

		# WARNING: Make sure the Labels are named 'Label' and are in CMYK order
		counter.get_node("Label").text = str(new_ink_counter[index])
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
	_set_ink_counter(prev_snapshot.ink_counter)


func _on_delete_button_up() -> void:
	printing_canvas.reset_grid_visuals()
	_set_ink_counter([0, 0, 0, 0])


func _on_history_added(num: int, msg: String) -> void :
	var history_card: PanelContainer = HISTORY_CARD_SCENE.instantiate()

	history_card.set_values(num, msg)
	history_list.add_child(history_card)
	history_list.move_child(history_card, 0)


func _on_history_removed() -> void :
	var latest_history_card = history_list.get_child(0)

	if latest_history_card :
		latest_history_card.queue_free()


func _on_history_cleaned() -> void :
	for history_card in history_list.get_children() :
		history_card.queue_free()
