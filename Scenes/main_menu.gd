extends Control


func _ready() -> void :
	ColorManager.reset()
	SaveStatesManager.reset() 
	CursorManager.reset()



func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/LevelSelector/level_selector.tscn")
	pass # Replace with function body.


func _on_settings_button_down() -> void:
	$Settings.open()


func _on_quit_button_down() -> void:
	# disable the quit button if on web
	if (!OS.has_feature("web")) :
		get_tree().quit()
