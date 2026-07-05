extends TextureButton

signal paint_requested(print_request: Dictionary)

var grid_alignment: String
var grid_index: int


func _on_button_down() -> void :
	if (!ColorManager.is_selecting_color()) :
		return
		
	paint_requested.emit({
		"grid_alignment": grid_alignment,
		"grid_index": grid_index,
	})
