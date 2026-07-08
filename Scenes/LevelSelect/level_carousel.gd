extends ScrollContainer

@onready var hbox: HBoxContainer = $HBoxContainer

var current_card_index: int = 0
var card_width: float = 0.0
var is_dragging: bool = false
var snap_tween: Tween

func _ready() -> void:
	# Wait one frame for Godot to layout UI sizing elements accurately
	await get_tree().process_frame
	
	# Calculate how wide a single level selection card step is
	if hbox.get_child_count() > 0:
		var first_card = hbox.get_child(0) as Control
		card_width = first_card.size.x + hbox.get_theme_constant("separation")
	
	# Connect to the built-in gui_input signal to detect when dragging ends
	gui_input.connect(_on_gui_input)

func _process(_delta: float) -> void:
	# If the user is actively dragging, don't try to fight them with snapping math
	if is_dragging:
		return

func _on_gui_input(event: InputEvent) -> void:
	# Detect mouse drag or touch screen swiping movements
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_dragging = true
		if snap_tween: 
			snap_tween.kill() # Stop any active snaps if they start dragging mid-slide
			
	# Detect when they completely lift their finger / release the mouse click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if is_dragging:
			is_dragging = false
			_snap_to_nearest_card()

func _snap_to_nearest_card() -> void:
	# Math check: figure out which level card slot we are closest to right now
	var current_scroll_x: float = scroll_horizontal
	current_card_index = round(current_scroll_x / card_width)
	
	# Restrict the target range to the bounds of our actual child count list
	current_card_index = clamp(current_card_index, 0, hbox.get_child_count() - 1)
	
	var target_scroll_pos: float = current_card_index * card_width
	
	# Smoothly animate the horizontal scroll into place!
	snap_tween = create_tween()
	snap_tween.set_trans(Tween.TRANS_CUBIC)
	snap_tween.set_ease(Tween.EASE_OUT)
	snap_tween.tween_property(self, "scroll_horizontal", target_scroll_pos, 0.3)
	
	print("Snapped onto Level Card Index: ", current_card_index + 1)
