extends ColorRect

@export var holes_root: Control
@export var feather: float = 0.02

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() and not is_visible_in_tree():
		return

	if not holes_root or not material:
		return

	var viewport_size := get_viewport_rect().size
	if viewport_size.x == 0 or viewport_size.y == 0:
		return

	var centers := PackedVector2Array()
	var sizes := PackedVector2Array()

	for child in holes_root.get_children():
		var rect_ctrl := child as Control
		if not rect_ctrl:
			continue

		# hide the cutout rects outside the editor
		rect_ctrl.visible = Engine.is_editor_hint()

		var rect := rect_ctrl.get_global_rect()
		var center := rect.position + rect.size * 0.5
		var half_size := rect.size * 0.5
		centers.append(center / viewport_size)
		sizes.append(half_size / viewport_size)

	var mat := material as ShaderMaterial
	mat.set_shader_parameter("hole_centers", centers)
	mat.set_shader_parameter("hole_sizes", sizes)
	mat.set_shader_parameter("hole_count", centers.size())
	mat.set_shader_parameter("feather", feather)
