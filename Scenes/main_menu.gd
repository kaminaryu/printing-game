extends Control


func _ready() -> void :
	# disable the quit button if on web
	if (OS.has_feature("web")) :
		$VBoxContainer/Quit.hide()
	else :
		$VBoxContainer/Quit.show()


func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
	pass # Replace with function body.


func _on_settings_button_down() -> void:
	$Settings.open()


func _on_quit_button_down() -> void:
	get_tree().quit()
	pass # Replace with function body.
