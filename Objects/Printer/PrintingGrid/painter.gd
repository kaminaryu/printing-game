extends Node2D

signal paint_requested(print_request: Dictionary)
signal hovered(alignment: String, index: int)
signal unhovered()

var grid_alignment: String
var grid_index: int


func _ready() -> void:
	$Button.button_down.connect(_on_button_down)
	$Button.mouse_entered.connect(_on_mouse_entered)
	$Button.mouse_exited.connect(_on_mouse_exited)
	ColorManager.color_changed.connect(_change_painter_color)
	$BrushItself.modulate = Color.from_string(ColorManager.get_selected_color(), "#000")


func show_col_shadow() -> void :
	$BrushItself/ShadowCol.show()


func show_row_shadow() -> void :
	$BrushItself/ShadowRow.show()


func _change_painter_color() -> void :
	var color_key := ColorManager.get_selected_color()

	$BrushItself.modulate = Color.from_string(color_key, "#000")


func _on_button_down() -> void :
	if (!ColorManager.is_selecting_color()) :
		return
		
	paint_requested.emit({
		"grid_alignment": grid_alignment,
		"grid_index": grid_index,
	})


func _on_mouse_entered() -> void:
	CursorManager.set_roller()
	hovered.emit(grid_alignment, grid_index)


func _on_mouse_exited() -> void:
	CursorManager.set_cursor()
	unhovered.emit()


func _on_ink_channel_change() -> void :
	_change_painter_color()
