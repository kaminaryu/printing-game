extends Control

func _on_cyan_button_button_down() -> void:
	ColorManager.selected_color = 0


func _on_magenta_button_button_down() -> void:
	ColorManager.selected_color = 1


func _on_yellow_button_button_down() -> void:
	ColorManager.selected_color = 2


func _on_key_button_button_down() -> void:
	ColorManager.selected_color = 3
