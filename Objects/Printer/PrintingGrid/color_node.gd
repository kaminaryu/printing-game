extends TextureButton

signal paint_requested(print_request: Dictionary)

var grid_alignment: String
var grid_index: int
var ink_channel: String


func _on_button_down() -> void :
	paint_requested.emit({
		"grid_alignment": grid_alignment,
		"grid_index": grid_index,
		"ink_channel": ink_channel,
	})
