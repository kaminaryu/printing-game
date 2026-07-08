extends Node

signal level_increased
signal level_decreased

var current_level_num: int = 1

const SAVE_PATH := "user://level_data.json"


func increase_level() -> void :
	current_level_num += 1
	level_increased.emit()

func decrease_level() -> void :
	current_level_num -= 1
	level_decreased.emit()


func save_level_data(time_elapsed_ms: float) -> void:
	var save_data: Dictionary = {}
	
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			if json.parse(json_string) == OK and typeof(json.data) == TYPE_DICTIONARY:
				save_data = json.data
	
	var level_key = str(current_level_num)
	
	# Assume we want to save this score unless a better one exists
	var should_save_new_time: bool = true
	
	# Check if this level already has a saved record
	if save_data.has(level_key) and typeof(save_data[level_key]) == TYPE_DICTIONARY:
		var existing_record: Dictionary = save_data[level_key]
		if existing_record.has("time_elapsed"):
			var saved_time: int = int(existing_record["time_elapsed"])
			
			# If the saved time is valid (not -1) and is faster/smaller than our current attempt, do not overwrite it
			if saved_time != -1 and saved_time <= time_elapsed_ms:
				should_save_new_time = false
	
	# Update or create the entry if it's a new personal best
	if should_save_new_time:
		save_data[level_key] = {
			"level_completed": true,
			"time_elapsed": time_elapsed_ms
		}
	else:
		# Keep old time, but ensure the completed flag stays true
		save_data[level_key]["level_completed"] = true
	
	var file_write = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file_write:
		file_write.store_string(JSON.stringify(save_data))
		file_write.close()


func load_level_data() -> Dictionary:
	var default_data = {
		"level_completed": false,
		"time_elapsed": -1.0
	}
	
	if not FileAccess.file_exists(SAVE_PATH):
		return default_data
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		if json.parse(json_string) == OK and typeof(json.data) == TYPE_DICTIONARY:
			var save_data: Dictionary = json.data
			var level_key = str(current_level_num)
			
			# Check if this specific level exists in the save file
			if save_data.has(level_key) and typeof(save_data[level_key]) == TYPE_DICTIONARY:
				return save_data[level_key]
				
	return default_data
