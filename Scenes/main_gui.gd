extends Control


func _on_pause_button_button_down() -> void:
	$PauseMenu.show()
	get_tree().paused = true
