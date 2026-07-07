extends Control

func _on_continue_button_down() -> void:
	get_tree().paused = false
	hide()


func _on_settings_button_down() -> void:
	$Settings.open()
	pass # Replace with function body.


func _on_main_menu_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
