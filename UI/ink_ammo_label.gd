extends HBoxContainer

@onready var manager = $"../../.."

@onready var c_label = $Cyan
@onready var m_label = $Magenta
@onready var y_label = $Yellow
@onready var k_label = $Key



func _ready() -> void:
	manager.ink_inventory_updated.connect(_on_ink_updated)
	
func _on_ink_updated(channel: String, count: int) -> void:
	var target_label: Label = null
	match channel:
		"c": target_label = c_label
		"m": target_label = m_label
		"y": target_label = y_label
		"k": target_label = k_label
		
	if count == -1:
		target_label.text = "∞"
	else:
		target_label.text = str(count)
