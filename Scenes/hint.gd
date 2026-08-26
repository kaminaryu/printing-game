extends TextureButton

@onready var paper_guide = $"../PaperGuide"
@onready var main = get_tree().current_scene

func _on_pressed() -> void:
	paper_guide.toggle_hint()
	main.play_button_sound()
