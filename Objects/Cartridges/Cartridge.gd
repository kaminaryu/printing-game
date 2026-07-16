extends Node2D
class_name Cartridge

@export var selected_color_index: int = 0

@onready var label: Label = $Label 
@onready var area: Area2D = $Area2D

const POPUP_HEIGHT: float = 60.0
const DISABLED_SINK_DEPTH: float = 25.0

var base_y: float = 0.0
var is_disabled: bool = false
var active_tween: Tween

func _ready() -> void:
	base_y = position.y
	if area:
		area.input_event.connect(_on_input_event)
		area.mouse_entered.connect(_on_mouse_entered)
		area.mouse_exited.connect(_on_mouse_exited)
	
	if ColorManager.has_signal("color_changed"):
		ColorManager.color_changed.connect(_on_global_color_changed)
		
	_update_selection_state(false)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_disabled: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ColorManager.selected_color = selected_color_index
		CursorManager.set_cursor()
		
		if not ColorManager.has_signal("color_changed"):
			get_tree().call_group("cartridges", "_on_global_color_changed")

## 🎯 This handles the visual state transition (selected vs unselected)
func _update_selection_state(animate: bool = true) -> void:
	if is_disabled: return
	
	var is_selected: bool = (ColorManager.selected_color == selected_color_index)
	var target_y: float = base_y - POPUP_HEIGHT if is_selected else base_y
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	if animate:
		active_tween = create_tween()
		active_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		active_tween.tween_property(self, "position:y", target_y, 0.15)
	else:
		position.y = target_y

func _on_global_color_changed() -> void:
	_update_selection_state(true)

func update_ink(remaining_count: int) -> void:
	if label:
		if remaining_count == -1:
			label.text = "INF"
		else:
			label.text = str(remaining_count)
	if remaining_count == 0:
		_disable_cartridge()
	else:
		_enable_cartridge()
			
func _on_mouse_entered():
	if is_disabled: return
	if ColorManager.selected_color == selected_color_index: return
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(self, "position:y", base_y - POPUP_HEIGHT, 0.15)
	
func _on_mouse_exited():
	if is_disabled: return
	if ColorManager.selected_color == selected_color_index: return
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(self, "position:y", base_y, 0.15)
	
func _disable_cartridge() -> void:
	if is_disabled: return
	is_disabled = true
	
	if active_tween and active_tween.is_valid():
		active_tween.kill()
		
	active_tween = create_tween().set_parallel(true) 
	active_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(self, "position:y", base_y + DISABLED_SINK_DEPTH, 0.25)
	active_tween.tween_property(self, "modulate", Color(0.4, 0.4, 0.4, 0.8), 0.25) 
	
func _enable_cartridge() -> void:
	if not is_disabled: return
	is_disabled = false
	
	_update_selection_state(true)
	
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate", Color.WHITE, 0.25)
