extends TextureRect

@onready var button := $ArrowButton
@onready var animation := $AnimationPlayer

var in_view := false;

func _on_arrow_button_mouse_entered() -> void:
	if in_view: return;
	var tween = create_tween().set_parallel(true);
	tween.tween_property(self, "position:x", 1160, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
	tween.tween_property(self, "rotation_degrees", -21, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);


func _on_arrow_button_mouse_exited() -> void:
	if in_view: return;
	var tween = create_tween().set_parallel(true);
	tween.tween_property(self, "position:x", 1164, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
	tween.tween_property(self, "rotation_degrees", -20.3, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);


func _on_arrow_button_pressed() -> void:
	show_hint()

func show_hint() -> void:
	if !in_view:
		in_view = true;
		animation.play("slide_in");
	else:
		
		animation.play("slide_out")
		await animation.animation_finished;
		in_view = false;
