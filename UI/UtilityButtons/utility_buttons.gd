extends Control

@onready var level_manager = $"../.."


func _on_reset_pressed() -> void:
	level_manager.reset_entire_level()
	pass # Replace with function body.


func _on_redo_pressed() -> void:
	SaveStatesManager.redo_action()


func _on_undo_pressed() -> void:
	SaveStatesManager.undo_action()
