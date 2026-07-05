extends Node2D

func _process(_delta: float) -> void :
	position = get_global_mouse_position() + Vector2(8, -8)
	modulate = Color.from_string(ColorManager.get_selected_color(), "#fff")
