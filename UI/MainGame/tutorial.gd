extends Control

signal prev_tutorial_requested
signal next_tutorial_requested


func enter() -> void :
	show()
	$AnimationPlayer.play("FadeIn")

func exit() -> void :
	hide()


func _on_prev_button_up() -> void:
	prev_tutorial_requested.emit()


func _on_next_button_up() -> void:
	next_tutorial_requested.emit()
