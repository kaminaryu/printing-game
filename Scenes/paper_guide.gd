extends TextureRect

@onready var button := $ArrowButton
@onready var animation := $AnimationPlayer

var in_view := false

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if in_view:
			var local_mouse_pos = get_local_mouse_position()
			var rect = Rect2(Vector2.ZERO, size)
			
			if not rect.has_point(local_mouse_pos):
				var button_rect = Rect2(button.position, button.size)
				if not button_rect.has_point(button.get_local_mouse_position()):
					show_hint()

func _on_arrow_button_mouse_entered() -> void:
	if in_view: return
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:x", 1160, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "rotation_degrees", -21, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)


func _on_arrow_button_mouse_exited() -> void:
	if in_view: return
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:x", 1164, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "rotation_degrees", -20.3, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)


func _on_arrow_button_pressed() -> void:
	show_hint()

func show_hint() -> void:
	if !in_view:
		in_view = true
		animation.play("slide_in")
	else:
		animation.play("slide_out")
		await animation.animation_finished
		in_view = false
