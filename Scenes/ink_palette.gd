extends HBoxContainer

@onready var button = $Cyan/CyanButton

func _ready() -> void:
	# get the first child's (cyan) button group
	var group: ButtonGroup = button.button_group
	
	if group:
		# check if any on the button in the group is pressed
		group.pressed.connect(_on_bottle_selected)

func _on_bottle_selected(button: BaseButton) -> void:
	match button.name:
		"CyanButton":
			ColorManager.selected_color = 0
		"MagentaButton":
			ColorManager.selected_color = 1
		"YellowButton":
			ColorManager.selected_color = 2
		"KeyButton":
			ColorManager.selected_color = 3

	CursorManager.set_cursor()
