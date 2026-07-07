extends Control


func init(level: LevelData) -> void :
	$LevelThumbnail.update_preview(level)


func _process(_delta: float) -> void :
	$LevelLabel/LevelNum.text = str(GameMaster.current_level_num)


func _on_previous_button_down() -> void:
	GameMaster.decrease_level()


func _on_play_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")	


func _on_next_button_down() -> void:
	GameMaster.increase_level()
