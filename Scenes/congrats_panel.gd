extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_discord_pressed() -> void:
	OS.shell_open("https://discord.gg/gSKz8u7G8m")

func _on_itch_pressed() -> void:
	OS.shell_open("https://novarchitects.itch.io/riso")


func _on_finish_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
