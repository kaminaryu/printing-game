extends Node2D

func _input(event: InputEvent) -> void :
	if (event.is_action_pressed("undo")) :
		SaveStatesManager.undo_action()

	elif (event.is_action_pressed("redo")) :
		SaveStatesManager.redo_action()
