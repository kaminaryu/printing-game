extends VBoxContainer

# References to your ink text labels
@onready var remaining_labels = {
	"c": $"Remaining Ink/Cyan",
	"m": $"Remaining Ink/Magenta",
	"y": $"Remaining Ink/Yellow",
	"k": $"Remaining Ink/Key"
}

# References to your actual palette buttons
@onready var palette_buttons = {
	"c": $"Ink Palette/Cyan",
	"m": $"Ink Palette/Magenta",
	"y": $"Ink Palette/Yellow",
	"k": $"Ink Palette/Key"
}

func _ready() -> void:
	_setup_button_group()

## Groups the buttons together so they behave like radio selections
func _setup_button_group() -> void:
	var button_group = ButtonGroup.new()
	
	for channel in palette_buttons.keys():
		var btn = palette_buttons[channel] as BaseButton
		if btn:
			btn.button_group = button_group
			btn.toggle_mode = true
			
	# Connect the unified signal
	button_group.pressed.connect(_on_palette_button_pressed)

## Call this from your Game Manager whenever a level finishes loading
func update_visible_channels(level_data: LevelData) -> void:
	# Fetch the channels that are defined in this level's ink limits
	var allowed_channels: Array = level_data.available_channels
	
	var first_visible_button: BaseButton = null
	
	# Loop through every possible channel and set its visibility
	for channel in ["c", "m", "y", "k"]:
		var is_available: bool = allowed_channels.has(channel)
		
		# Show/Hide the ink counters
		if remaining_labels.has(channel) and remaining_labels[channel]:
			remaining_labels[channel].visible = is_available
			
		# Show/Hide the selection buttons
		if palette_buttons.has(channel) and palette_buttons[channel]:
			var btn = palette_buttons[channel]
			btn.visible = is_available
			
			# Keep track of the first visible one to auto-select it
			if is_available and first_visible_button == null:
				first_visible_button = btn

	# Auto-select the first visible button so the player isn't painting with a hidden channel
	if first_visible_button:
		first_visible_button.button_pressed = true
		_on_palette_button_pressed(first_visible_button)


## Triggered when a player selects a color block
func _on_palette_button_pressed(button: BaseButton) -> void:
	# Match the node names in your image ("Cyan", "Magenta", "Yellow", "Key")
	match button.name:
		"Cyan": ColorManager.selected_color = 0
		"Magenta": ColorManager.selected_color = 1
		"Yellow": ColorManager.selected_color = 2
		"Key": ColorManager.selected_color = 3

	CursorManager.set_cursor()
