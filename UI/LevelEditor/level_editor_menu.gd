extends Control

@export var blur_panel: Panel
@export var level_editor_settings: Control

@export var menu: Control
@export var preview_grid: Control
@export var current_level_label: Label

@export var prev_button: TextureButton
@export var double_prev_button: TextureButton

@export var settings_menu: Control

const double_arrow_value: int = 5

var selected_level = 1


func _ready() -> void :
	update_level_label()
	preview_grid.generate_preview(selected_level)


func _process(_delta: float) -> void :
	# disabled single arrow button
	if (selected_level <= 1) :
		prev_button.disabled = true
		prev_button.modulate.a = 0.25
	else :
		prev_button.disabled = false
		prev_button.modulate.a = 1


	# disable double arrow button	
	if (selected_level <= double_arrow_value) :
		double_prev_button.disabled = true
		double_prev_button.modulate.a = 0.25
	else :
		double_prev_button.disabled = false
		double_prev_button.modulate.a = 1


###########
# Actions #
###########
func update_level_label() -> void:
	current_level_label.text = "level %d" % selected_level


func slide_menu() -> void:
	var slide = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true);
	
	# shit is already opened
	if get_tree().paused:
		slide.tween_property(menu, "position:x", 1280, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 0, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);

		await slide.finished;
	
		get_tree().paused = false
		blur_panel.visible = false

	else:
		slide.tween_property(menu, "position:x", 735, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 2.5, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);

		get_tree().paused = true
		blur_panel.visible = true


func _get_parent() -> Control :
	var parent_name: String = "LevelEditor"
	var parent: Control = get_parent()

	assert(
		parent.name == parent_name,
		"ERROR: LEVEL EDITOR MENU MUST BE THE CHILD OF LEVEL EDITOR (Expected Parent Name: %s | Current Parent Name: %s)" % [parent_name, parent.name]
	)

	return parent


func _display_preview() -> void :
	preview_grid.generate_preview(selected_level)
	update_level_label()


func _load_level_data_to_editor() -> void :
	var level_editor: Control = _get_parent()
	level_editor.load_level_data(selected_level)



###########
# Signals #
###########
# make the button pop up a bit when hovered
func _on_pencil_button_mouse_entered() -> void:
	# shit is already opened no need to wiggle it
	if get_tree().paused: return

	var tween = create_tween();
	tween.tween_property(menu, "position:x", 1280-10, .2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);;

	var level_editor: Control = _get_parent()
	level_editor.put_panel_on_top(self)


func _on_pencil_button_mouse_exited() -> void:
	# shit is already opened no need to wiggle it
	if get_tree().paused: return

	var tween = create_tween();
	tween.tween_property(menu, "position:x", 1280, .2);


func _on_pencil_button_button_down() -> void:
	var level_editor: Control = _get_parent()
	level_editor.put_panel_on_top(self)
	slide_menu()


func _on_back_button_button_down() -> void:
	slide_menu()


func _on_exit_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


# -- Level chooser buttons -- 
func _on_prev_level_button_down() -> void:
	selected_level += -1
	_display_preview()

func _on_next_level_button_down() -> void:
	selected_level += 1
	_display_preview()


func _on_double_prev_level_button_down() -> void:
	selected_level += -double_arrow_value
	_display_preview()


func _on_double_next_level_button_down() -> void:
	selected_level += double_arrow_value
	_display_preview()


# -- Level action buttons -- 
func _on_load_button_up() -> void:
	_load_level_data_to_editor()


func _on_save_button_up() -> void:
	level_editor_settings.save_level_metadata(selected_level)
	_display_preview()
