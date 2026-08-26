extends Control

signal prev_tutorial_requested
signal next_tutorial_requested

enum TutorialCondition {
	INK_SELECTION,
	PAINT_CANVAS,
	PLAY_BUTTON,
}

@export var tutorial_condition := TutorialCondition.PLAY_BUTTON

@onready var buttons := $Panel/TextMargin/VBoxContainer/HBoxContainer


func enter() -> void :
	show()
	$AnimationPlayer.play("FadeIn")

	match tutorial_condition:
		TutorialCondition.INK_SELECTION :
			# reset the ink selection when user go prev tutorial
			ColorManager.selected_color = ColorManager.SelectedColors.UNDEFINED 

			ColorManager.color_changed.connect(_on_condition_met)

		TutorialCondition.PAINT_CANVAS :
			var main: Node2D = get_tree().current_scene
			var printing_canvas = main.get_node("PrintingCanvas")

			# reset the canvas when user go prev tutorial
			printing_canvas.reset_grid_visuals(main.current_level_data)

			printing_canvas.paint_cascade_finished.connect(_on_condition_met)


func exit() -> void :
	if ColorManager.color_changed.is_connected(_on_condition_met):
		ColorManager.color_changed.disconnect(_on_condition_met)

	var printing_canvas = get_tree().current_scene.get_node_or_null("PrintingCanvas")
	if printing_canvas and printing_canvas.paint_cascade_finished.is_connected(_on_condition_met):
		printing_canvas.paint_cascade_finished.disconnect(_on_condition_met)

	hide()


func _on_condition_met() -> void:
	next_tutorial_requested.emit()


func _on_prev_button_up() -> void:
	prev_tutorial_requested.emit()


func _on_next_button_up() -> void:
	next_tutorial_requested.emit()
