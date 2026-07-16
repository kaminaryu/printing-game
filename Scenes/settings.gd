extends Control

@onready var master_slider := $VBoxContainer2/MasterVol/MasterSlider
@onready var music_slider  := $VBoxContainer2/MusicVol/MusicSlider
@onready var sfx_slider    := $VBoxContainer2/SFXVol/SFXSlider

func open() -> void :
	_set_sliders_to_bus_values()
	show()
	create_tween().tween_property(self, "position:x", 0, .3).from(655).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART);

func _set_sliders_to_bus_values() -> void :
	# &"Master" makes it a StringName instead of normal string
	# -> Faster lookup cuz they point to the same memory and also no char by char check
	var master_bus = AudioServer.get_bus_index(&"Master")
	var music_bus =  AudioServer.get_bus_index(&"Music")
	var sfx_bus =    AudioServer.get_bus_index(&"SFX")

	var master_bus_volume = AudioServer.get_bus_volume_db(master_bus)
	var music_bus_volume  = AudioServer.get_bus_volume_db(music_bus)
	var sfx_bus_volume  =   AudioServer.get_bus_volume_db(sfx_bus)

	master_slider.value = db_to_linear(master_bus_volume)
	music_slider.value  = db_to_linear(music_bus_volume)
	sfx_slider.value    = db_to_linear(sfx_bus_volume)
	print(db_to_linear(music_bus_volume))


## Converts 0 - 100 slider value to dB and updates the bus
func _set_bus_volume_percent(bus_name: String, percent: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)

	if bus_index != -1:
			# linear_to_db handles the logarithmic math for you
		var db_value = linear_to_db(percent)
		AudioServer.set_bus_volume_db(bus_index, db_value)



func _on_master_slider_value_changed(value: float) -> void:
	_set_bus_volume_percent(&"Master", value)


func _on_music_slider_value_changed(value: float) -> void:
	_set_bus_volume_percent(&"Music", value)


func _on_audio_slider_value_changed(value: float) -> void:
	_set_bus_volume_percent(&"SFX", value)


func _on_texture_button_button_down() -> void:
	
	await create_tween().tween_property(self, "position:x", 655, .3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).finished;
	hide()


func _on_discord_pressed() -> void:
	OS.shell_open("https://discord.gg/gSKz8u7G8m")

func _on_itchio_pressed() -> void:
	OS.shell_open("https://novarchitects.itch.io")

func _on_x_pressed() -> void:
	OS.shell_open("https://x.com/novaarchitects")

func _on_threads_pressed() -> void:
	OS.shell_open("https://www.threads.com/@supernovarchitects")


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			
		2: # Borderless Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
