extends Control

@export var fadeOutScreen: Panel;
@export var animationPlayer: AnimationPlayer;
@export var camera2d: Camera2D;
@onready var settings := $Settings;

@onready var game_start = $GameStart


func _ready() -> void:
	fadeOutTransition();
	CursorManager.reset()
	
func fadeOutTransition() -> void:
	fadeOutScreen.modulate.a = 1.0;
	var fadeout_tween = create_tween()
	fadeout_tween.tween_property(fadeOutScreen, "modulate:a", 0.0, 1.0);
	await fadeout_tween.finished;
	fadeOutScreen.visible = false;

func _on_play_pressed() -> void:
	
	animationPlayer.play("papermasuk");
	game_start.play()
	await animationPlayer.animation_finished
	#
	#var camerazoom = create_tween().set_parallel(true);
	 #
	#camerazoom.tween_property(camera2d, "global_position", Vector2(250, 190), 1).set_trans(Tween.TRANS_SINE).set_trans(Tween.TRANS_LINEAR);
	#camerazoom.tween_property(camera2d, "zoom", Vector2(5,5), 1).set_trans(Tween.TRANS_SINE).set_trans(Tween.TRANS_LINEAR);
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/LevelSelector/level_selector.tscn")


func _on_options_pressed() -> void:
	$Settings.open();


func _on_credits_pressed() -> void:
	animationPlayer.play("show_credits");


func _on_back_pressed() -> void:
	animationPlayer.play("show_credits_2")
