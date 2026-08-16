extends Button

var is_listening: bool = false

func _on_button_up() -> void:
	is_listening = true

func _process(delta) -> void:
	var event := InputMap.action_get_events("select_cyan")[0]

	if (event is InputEventKey) :
		text = event.as_text()


func _input(event: InputEvent) -> void :
	if (not is_listening): return

	if event is InputEventKey and event.pressed :
		# ignore modifier
		if (event.keycode in [KEY_SHIFT, KEY_CTRL, KEY_META, KEY_ALT]): return 

		InputMap.action_erase_events("select_cyan")
		InputMap.action_add_event("select_cyan", event)
		is_listening = false
		get_viewport().set_input_as_handled() # stop the input / flag the input as handled
