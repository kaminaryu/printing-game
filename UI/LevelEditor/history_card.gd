extends PanelContainer

@export var num_label: Label
@export var msg_label: RichTextLabel

func set_values(num: int, message: String) -> void :
	num_label.text = str(num)
	msg_label.text = message
