extends Control

@export var blur_panel: Panel

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
		slide.tween_property(menu, "position:x", 1126, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 0, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);

		await slide.finished;
	
		get_tree().paused = false;
		blur_panel.visible = false;

	else:
		slide.tween_property(menu, "position:x", 580, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 2.5, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);

		get_tree().paused = true;
		blur_panel.visible = true;


func _draw_level_to_canvas() -> void :
	var parent_name: String = "LevelEditor"
	var level_editor: Control = get_parent()

	assert(
		level_editor.name == parent_name,
		"ERROR: LEVEL EDITOR MENU MUST BE THE CHILD OF LEVEL EDITOR (Expected Parent Name: %s | Current Parent Name: %s)" % [parent_name, level_editor.name]
	)

	level_editor.draw_level_to_canvas(selected_level)


###########
# Signals #
###########
# make the button pop up a bit when hovered
func _on_pencil_button_mouse_entered() -> void:
	# shit is already opened
	if get_tree().paused: return

	var tween = create_tween();
	tween.tween_property(menu, "position:x", 1126-10, .2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);;
	print('thez');


func _on_pencil_button_mouse_exited() -> void:
	# shit is already opened
	if get_tree().paused: return

	var tween = create_tween();
	tween.tween_property(menu, "position:x", 1126, .2);


func _on_pencil_button_button_down() -> void:
	slide_menu()


func _on_back_button_button_down() -> void:
	slide_menu()


func _on_prev_level_button_down() -> void:
	selected_level += -1
	preview_grid.generate_preview(selected_level)
	update_level_label()
	_draw_level_to_canvas()

func _on_next_level_button_down() -> void:
	selected_level += 1
	preview_grid.generate_preview(selected_level)
	update_level_label()
	_draw_level_to_canvas()


func _on_exit_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_double_prev_level_button_down() -> void:
	selected_level += -double_arrow_value
	preview_grid.generate_preview(selected_level)
	update_level_label()
	_draw_level_to_canvas()


func _on_double_next_level_button_down() -> void:
	selected_level += double_arrow_value
	preview_grid.generate_preview(selected_level)
	update_level_label()
	_draw_level_to_canvas()


func _on_level_settings_button_down() -> void:
	settings_menu.open()
