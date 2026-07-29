extends TextureButton

const brightness: float = 1.5
const scalar: float = 1.1

func _ready() -> void :
	pivot_offset_ratio = Vector2(0.5, 0.5)

func _on_mouse_entered() -> void:
	if disabled : 
		_on_mouse_exited()
		return

	modulate = Color(brightness, brightness, brightness)
	scale = Vector2(scalar, scalar)


func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1)
	scale = Vector2(1, 1)
