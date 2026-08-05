extends PanelContainer


func _on_from_scratch_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/LevelEditor/level_editor_paper_setup.tscn")

func _on_load_level_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/LevelEditor/level_editor_level_loader.tscn")


func _on_back_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
