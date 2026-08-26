extends Control

@onready var slot_containers = {
	"c": $"Ink Palette/Cyan",
	"m": $"Ink Palette/Magenta",
	"y": $"Ink Palette/Yellow",
	"k": $"Ink Palette/Key"
}

@onready var remaining_labels = {
	"c": $"Ink Palette/Cyan/CyanLabel",
	"m": $"Ink Palette/Magenta/MagentaLabel",
	"y": $"Ink Palette/Yellow/YellowLabel",
	"k": $"Ink Palette/Key/KeyLabel"
}

@onready var palette_buttons = {
	"c": $"Ink Palette/Cyan/CyanButton",
	"m": $"Ink Palette/Magenta/MagentaButton",
	"y": $"Ink Palette/Yellow/YellowButton",
	"k": $"Ink Palette/Key/KeyButton"
}

func _ready() -> void:
	_setup_button_group()

func _setup_button_group() -> void:
	var button_group = ButtonGroup.new()
	
	for channel in palette_buttons.keys():
		var btn = palette_buttons[channel] as BaseButton
		if btn:
			btn.button_group = button_group
			btn.toggle_mode = true

	button_group.pressed.connect(_on_palette_button_pressed)

func update_visible_channels(level_data: LevelData) -> void:
	var allowed_channels: Array = level_data.available_channels
	var first_visible_button: BaseButton = null
	
	for channel in ["c", "m", "y", "k"]:
		var is_available: bool = allowed_channels.has(channel)
		
		if slot_containers.has(channel) and slot_containers[channel]:
			slot_containers[channel].visible = is_available
			
		if is_available and palette_buttons.has(channel) and palette_buttons[channel]:
			var btn = palette_buttons[channel]
			if first_visible_button == null:
				first_visible_button = btn

	if first_visible_button:
		first_visible_button.button_pressed = true
		_on_palette_button_pressed(first_visible_button)


func _on_palette_button_pressed(button: BaseButton) -> void:
	match button.name:
		"CyanButton": ColorManager.selected_color = 0
		"MagentaButton": ColorManager.selected_color = 1
		"YellowButton": ColorManager.selected_color = 2
		"KeyButton": ColorManager.selected_color = 3

	CursorManager.set_cursor()
