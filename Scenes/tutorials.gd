extends Control

signal tutorial_finished

@export var tutorial_scenes: Array[Control]

var current_tutorial_scene_index := 0

func _ready() -> void :
	# do not show tutorial if its not the first level
	if (GameMaster.current_level_num != 1) :
		hide()
		return

	# deselect ink selection
	ColorManager.selected_color = ColorManager.SelectedColors.UNDEFINED

	for tuto in tutorial_scenes :
		tuto.prev_tutorial_requested.connect(on_prev_requested)
		tuto.next_tutorial_requested.connect(on_next_requested)

	change_tutorial()


func on_prev_requested() :
	current_tutorial_scene_index -= 1
	change_tutorial()

func on_next_requested() :
	current_tutorial_scene_index += 1
	change_tutorial()


func change_tutorial() -> void :
	for i in range(len(tutorial_scenes)) :
		if (i == current_tutorial_scene_index) :
			tutorial_scenes[i].enter()
		else :
			tutorial_scenes[i].exit()

	if (current_tutorial_scene_index == len(tutorial_scenes)) :
		hide()
		tutorial_finished.emit()


func _on_grid_animator_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "Level Start") :
		current_tutorial_scene_index = 1
		change_tutorial()
