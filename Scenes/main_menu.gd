extends Control

@export var fadeOutScreen: Panel;
@export var animationPlayer: AnimationPlayer;
@export var camera2d: Camera2D;
@onready var settings := $Settings;

@onready var game_start = $GameStart


func _ready() -> void:
	fadeOutTransition();
	CursorManager.reset()

	if (BuildManager.is_web) :
		$VBoxContainer/Quit.hide()

	if (BuildManager.is_dev) :
		$Camera2D/VersionNumber.text = $Camera2D/VersionNumber.text + " (DEV)"


func fadeOutTransition() -> void:
	fadeOutScreen.modulate.a = 1.0;
	var fadeout_tween = create_tween()
	fadeout_tween.tween_property(fadeOutScreen, "modulate:a", 0.0, 1.0);
	await fadeout_tween.finished;
	fadeOutScreen.visible = false;


func _play_digital_button_sound() -> void : 
	var pitch := randf_range(0.7, 0.8)
	var main  := get_tree().current_scene
	var sfx   := main.get_node("DigitalButtonClick")

	sfx.pitch_scale = pitch
	sfx.play()
	

func _on_play_pressed() -> void:
	$PlayMenu.open()
	_play_digital_button_sound()


func _on_options_pressed() -> void:
	$Settings.open()


func _on_credits_pressed() -> void:
	animationPlayer.play("show_credits")
	_play_digital_button_sound()


func _on_back_pressed() -> void:
	animationPlayer.play("show_credits_2")
	_play_digital_button_sound()


func _on_quit_pressed() -> void:
	get_tree().quit()
