extends Node

signal color_changed

const CHANNELS: Array[String] = ["c", "m", "y", "k"]
const CHANNEL_NAMES: Array[String] = ["Cyan", "Magenta", "Yellow", "Key"]
const CHANNEL_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000"]

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

var selected_color: int = -1:
	set(value):
		selected_color = value
		color_changed.emit()



func get_selected_color_key() -> String :
	match selected_color :
		0: return "100"
		1: return "010"
		2: return "001"
		3: return "111"
		_: return ""

func reset() -> void :
	selected_color = -1


func get_selected_color() -> String :
	if (selected_color == -1) :
		return "#fff"
	return CHANNEL_COLORS[selected_color]


func get_channel_name(channel: String) -> String :
	var index: int = CHANNELS.find(channel)

	if (index == -1) :
		return "Undefined"

	return CHANNEL_NAMES[index]

func get_channel_hexcode(channel: String) -> String :
	var index: int = CHANNELS.find(channel)

	if (index == -1) :
		return "#670067"

	return CHANNEL_COLORS[index]


func get_color_channel() -> String :
	return CHANNELS[selected_color]


func is_selecting_color() -> bool :
	return selected_color != -1
