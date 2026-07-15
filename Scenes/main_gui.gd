extends Control

@export var pause_menu: Control;
@export var pause_button: TextureButton;
@export var settings: Control;
@export var blur_panel: Panel;

func _on_pause_button_button_down() -> void:
	#$PauseMenu.show()
	slide_menu()
	print("Pausing")
	#get_tree().paused = true


func slide_menu() -> void:
	var slide = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true);
	
	if get_tree().paused:
		slide.tween_property(pause_menu, "position:x", 1126, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 0, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		await slide.finished;
		#pause_button.visible = true;
		get_tree().paused = false;
		blur_panel.visible = false;
	else:
		#pause_button.visible = false;
		get_tree().paused = true;
		blur_panel.visible = true;
		slide.tween_property(pause_menu, "position:x", 580, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 2.5, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		


func _on_continue_button_down() -> void:
	slide_menu()


func _on_settings_button_down() -> void:
	settings.open()
	pass # Replace with function body.


func _on_main_menu_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


# Hovering effect
func _on_pause_button_focus_entered() -> void:
	var tween = create_tween();
	tween.tween_property(pause_menu, "position:x", 1126-10, .2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);;
	print('thez');


func _on_pause_button_focus_exited() -> void:
	var tween = create_tween();
	tween.tween_property(pause_menu, "position:x", 1126, .2);
