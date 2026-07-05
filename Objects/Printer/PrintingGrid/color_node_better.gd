extends Button

signal print_button_pressed(print_request: Dictionary)

var grid_alignment: String
var grid_index: int

func _on_button_down() -> void:
	print_button_pressed.emit({
		"grid_alignment": grid_alignment,
		"grid_index": grid_index
	})
