extends HBoxContainer

@onready var button = $Cyan

func _ready() -> void:
	# get the first child's (cyan) button group
	var group: ButtonGroup = button.button_group
	
	if group:
		# check if any on the button in the group is pressed
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

	CursorManager.set_cursor()
