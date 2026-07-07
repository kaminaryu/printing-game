extends Button

@export var level_num: int

func _on_button_down() -> void:
	GameMaster.current_level_num = int(text)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
