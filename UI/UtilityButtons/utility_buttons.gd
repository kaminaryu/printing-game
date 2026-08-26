extends Control

@onready var level_manager = $"../.."


func _on_reset_pressed() -> void:
	level_manager.reset_entire_level()
	level_manager.play_button_sound()


func _on_redo_pressed() -> void:
	SaveStatesManager.redo_action()
	level_manager.play_button_sound()

func _on_undo_pressed() -> void:
	SaveStatesManager.undo_action()
	level_manager.play_button_sound()
