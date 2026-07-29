extends Control

func open() -> void :
	show()
	create_tween().tween_property(self, "position:x", 0, .4).from(655).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);


func close() -> void :
	await create_tween().tween_property(self, "position:x", 655, .4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).finished;
	hide()


func _on_back_button_down() -> void:
	close()
