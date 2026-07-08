extends TextureButton

@onready var paper_guide = $"../PaperGuide"

func _on_pressed() -> void:
	paper_guide.show_hint()
