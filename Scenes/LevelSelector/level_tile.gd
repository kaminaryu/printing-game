extends Button

@export var level_num: int

func _on_button_down() -> void:
	GameMaster.current_level_num = int(text)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _ready() -> void:
	const FOLDER_PATH: String = "res://Resources/Levels"
	const EXTENSTION: String = ".tres"

	var file_count: int = 0
	var dir = DirAccess.open(FOLDER_PATH)

	if dir:
		dir.list_dir_begin() # init to start reading
		var file_name = dir.get_next()

		while file_name != "":
			# Check if it's a file (not a directory) and matches the naming scheme
			if not dir.current_is_dir():
				if file_name.ends_with(EXTENSTION):
					file_count += 1

			file_name = dir.get_next()

		dir.list_dir_end() # stop reading or smth

	else:
		print("An error occurred when trying to access the path: ", FOLDER_PATH)

	print("Total matching files: ", file_count)

	# var total_saves = count_files_with_pattern("res://saves/", "save_", ".json")
