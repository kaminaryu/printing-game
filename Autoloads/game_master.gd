extends Node

signal level_increased
signal level_decreased

var current_level_num: int = 1


func increase_level() -> void :
	current_level_num += 1
	level_increased.emit()

func decrease_level() -> void :
	current_level_num -= 1
	level_decreased.emit()
