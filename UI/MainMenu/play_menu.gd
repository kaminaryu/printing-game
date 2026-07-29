extends Control

@export var continue_button: Button

func _ready() -> void :
	continue_button.text = "Continue (level %d)" % GameMaster.current_level_num


func open() -> void :
	show()
	create_tween().tween_property(self, "position:x", 0, .3).from(655).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);


func _hide_animation() -> void :
	await create_tween().tween_property(self, "position:x", 655, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).finished;


func _on_back_button_down() -> void:
	await _hide_animation()
	hide()


func _on_continue_button_down() -> void:
	var parent: Node = get_parent()

	_hide_animation()

	parent.animationPlayer.play("papermasuk")
	parent.game_start.play()
	await parent.animationPlayer.animation_finished

	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_level_selection_button_down() -> void:
	var parent: Node = get_parent()

	_hide_animation()

	parent.animationPlayer.play("papermasuk")
	parent.game_start.play()
	await parent.animationPlayer.animation_finished

	get_tree().change_scene_to_file("res://Scenes/LevelSelect/level_select.tscn")


func _on_level_editor_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_editor.tscn")
