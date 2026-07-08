extends Node

# Route these directly to your new Node2D cartridge nodes!
@onready var cartridges = {
	"c": $CyanCartridge,
	"m": $MagentaCartridge,
	"y": $YellowCartridge,
	"k": $KeyCartridge
}

# Route these to the labels nested inside or alongside your Node2D nodes
@onready var remaining_labels = {
	"c": $CyanCartridge/CyanLabel,
	"m": $MagentaCartridge/MagentaLabel,
	"y": $YellowCartridge/YellowLabel,
	"k": $KeyCartridge/KeyLabel
}

# 🔒 This dictionary will lock down the starting coordinates so they can never drift
var original_y_positions: Dictionary = {}
const POPUP_HEIGHT = 50.0


func _ready() -> void:
	# Store the perfect baseline positions right at the start
	for channel in cartridges.keys():
		if cartridges[channel]:
			original_y_positions[channel] = cartridges[channel].position.y
			
	_setup_hover_animations()

## Connects hover signals to all your Node2D nodes dynamically
func _setup_hover_animations() -> void:
	for channel in cartridges.keys():
		var node = cartridges[channel] as Node2D
		if node and node.has_node("Area2D"):
			var area = node.get_node("Area2D") as Area2D
			# Pass both the node AND the channel key ("c", "m", etc.) to our hover handler
			area.mouse_entered.connect(_on_cartridge_hover.bind(node, channel, true))
			area.mouse_exited.connect(_on_cartridge_hover.bind(node, channel, false))
			area.input_event.connect(_on_cartridge_input.bind(channel))

## Handles smoothly sliding the Node2D using absolute, locked coordinates
func _on_cartridge_hover(cartridge_node: Node2D, channel: String, is_hovering: bool) -> void:
	# Pull our safe, original resting Y value from our dictionary
	var base_y = original_y_positions[channel]
	
	var hover_tween = create_tween()
	hover_tween.set_trans(Tween.TRANS_CUBIC)
	hover_tween.set_ease(Tween.EASE_OUT)
	
	if is_hovering:
		# Target an absolute position (Baseline minus 15 pixels)
		hover_tween.tween_property(cartridge_node, "position:y", base_y - POPUP_HEIGHT, 0.15)
	else:
		# Return directly to the exact baseline position, perfectly resetting it
		hover_tween.tween_property(cartridge_node, "position:y", base_y, 0.15)

## Call this from your Game Manager whenever a level finishes loading
func update_visible_channels(level_data: LevelData) -> void:
	var allowed_channels: Array = level_data.available_channels
	
	for channel in ["c", "m", "y", "k"]:
		var is_available: bool = allowed_channels.has(channel)
		
		if cartridges.has(channel) and cartridges[channel]:
			cartridges[channel].visible = is_available

## Triggered when clicking on the Node2D's Area2D zone
func _on_cartridge_input(_viewport: Node, event: InputEvent, _shape_idx: int, channel: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match channel:
			"c": ColorManager.selected_color = 0
			"m": ColorManager.selected_color = 1
			"y": ColorManager.selected_color = 2
			"k": ColorManager.selected_color = 3

		CursorManager.set_cursor()
		
func update_ink_label(channel: String, remaining_count: int) -> void:
	if remaining_labels.has(channel) and remaining_labels[channel]:
		# If ink is set to -1 (infinite ink), you can display an infinity symbol "∞" or leave it blank
		if remaining_count == -1:
			remaining_labels[channel].text = "∞"
		else:
			remaining_labels[channel].text = str(remaining_count)
