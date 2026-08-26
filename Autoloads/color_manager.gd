extends Node

signal color_changed

const CHANNEL_CODES: Array[String] = ["c", "m", "y", "k", "u"]
const CHANNEL_NAMES: Array[String] = ["Cyan", "Magenta", "Yellow", "Key", "Undefined"]
const CHANNEL_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000", "#FFFFFF"]

const COLOR_GLOSSARY: Dictionary = {
	"000": "#FFFFFF",

	"100": "#00FFFF",
	"010": "#FF00FF",
	"001": "#FFFF00",

	"110": "#0000FF",
	"101": "#00FF00",
	"011": "#FF0000",

	"210": "#007FFF",
	"120": "#670067",

	"201": "#00BF7F",
	"102": "#7FFF00",

	"021": "#FF007F",
	"012": "#FF7F00",

	"111": "#0E0E0E",
}

enum SelectedColors {
	CYAN,
	MAGENTA,
	YELLOW,
	KEY,
	UNDEFINED
}

var cartridge_pickup_sfx: AudioStream = preload("res://Assets/Audio/CartridgePickup.wav")

var selected_color_had_init := false

var selected_color: int = SelectedColors.UNDEFINED:
	set(value):
		selected_color = value
		CursorManager.set_cursor()
		color_changed.emit()

		# so it doesnt play on main menu when the selected_color is just initting
		if (selected_color_had_init) :
			_play_sound()

		selected_color_had_init = true


func _play_sound() -> void :
	var sfx = AudioStreamPlayer.new()
	sfx.stream = cartridge_pickup_sfx
	sfx.autoplay = true
	sfx.finished.connect(sfx.queue_free)

	get_tree().root.add_child.call_deferred(sfx)


func _ready() -> void :
	reset()


func reset() -> void :
	selected_color = -1


func get_selected_color_key() -> String :
	match selected_color :
		SelectedColors.CYAN:    return "100"
		SelectedColors.MAGENTA: return "010"
		SelectedColors.YELLOW:  return "001"
		SelectedColors.KEY:     return "111"
		_: return ""

func get_selected_color() -> String :
	return CHANNEL_COLORS[selected_color]


func get_channel_name(channel: String) -> String :
	var index: int = CHANNEL_CODES.find(channel)

	if (index == -1) :
		return "Undefined"

	return CHANNEL_NAMES[index]


func get_channel_hexcode(channel: String) -> String :
	var index: int = CHANNEL_CODES.find(channel)

	# not found
	if (index == -1) :
		return "#670067"

	return CHANNEL_COLORS[index]


func get_color_name(color_key: String) -> String :
	match color_key :
		"000": return "White"
		"100": return "Cyan"
		"010": return "Magenta"
		"001": return "Yellow"
		_: return "Undefined"


func get_color_channel() -> String :
	return CHANNEL_CODES[selected_color]


func is_channel_selected() -> bool :
	return selected_color != SelectedColors.UNDEFINED
