extends Control

@export var pause_menu: Control;
@export var settings: Control;
@export var blur_panel: Panel;

func _on_pause_button_button_down() -> void:
	slide_menu()



func slide_menu() -> void:
	var slide = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true);
	
	if get_tree().paused:
		_play_open_menu_sound()

		slide.tween_property(pause_menu, "position:x", 1126, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 0, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);

		await slide.finished;

		get_tree().paused = false;
		blur_panel.visible = false;

	else:
		_play_close_menu_sound()

		get_tree().paused = true;
		blur_panel.visible = true;

		slide.tween_property(pause_menu, "position:x", 580, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);
		slide.tween_property(blur_panel.material, "shader_parameter/blur_amount", 2.5, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);


func _play_button_sound() -> void :
	var pitch := randf_range(0.7, 0.8)
	var sfx   := $"DigitalButtonClick"

	sfx.pitch_scale = pitch
	sfx.play()


func _play_open_menu_sound() -> void :
	var pitch := randf_range(0.95, 1.05)
	var sfx   := $"MenuOpen"

	sfx.pitch_scale = pitch
	sfx.play()


func _play_close_menu_sound() -> void :
	var pitch := randf_range(0.95, 1.05)
	var sfx   := $"MenuClose"

	sfx.pitch_scale = pitch
	sfx.play()


func _on_continue_button_down() -> void:
	slide_menu()


func _on_settings_button_down() -> void:
	settings.open()


func _on_main_menu_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


# Hovering effect
func _on_pause_button_focus_entered() -> void:
	var tween = create_tween();
	tween.tween_property(pause_menu, "position:x", 1126-10, .2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);;


func _on_pause_button_focus_exited() -> void:
	var tween = create_tween();
	tween.tween_property(pause_menu, "position:x", 1126, .2);
