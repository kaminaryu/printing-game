extends HBoxContainer

func _ready() -> void:
	var group: ButtonGroup = get_child(0).button_group
	
	if group:
		group.pressed.connect(_on_bottle_selected)
		
func _on_bottle_selected(button: BaseButton) -> void:
	match button.name:
		"Cyan":
			ColorManager.selected_color = 0
		"Magenta":
			ColorManager.selected_color = 1
		"Yellow":
			ColorManager.selected_color = 2
		"Key":
			ColorManager.selected_color = 3
