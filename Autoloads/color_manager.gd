extends Node

const CHANNELS: Array[String] = ["c", "m", "y", "k"]
const CHANNEL_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000"]

# key = CMYK
const COLOR_GLOSSARY: Dictionary = {
	"000": "#FFFFFF",  # No ink (paper)

	"100": "#00FFFF",  # C
	"010": "#FF00FF",  # M
	"001": "#FFFF00",  # Y

	"110": "#0000FF",  # C + M -> BLUE
	"101": "#00FF00",  # C + Y -> GREEN
	"011": "#FF0000",  # M + Y -> RED

	"210": "#007FFF",  # C + M + C -> BLUE + C  => SkyBlue
	"120": "#670067",  # C + M + M -> BLUE + M  => Purple

	"201": "#00BF7F",  # C + Y + C -> GREEN + C => Torquise
	"102": "#7FFF00",  # C + Y + Y -> GREEN + Y => Lime

	"021": "#FF007F",  # M + Y + M -> RED + M   => HotPink
	"012": "#FF7F00",  # M + Y + Y -> RED + Y   => Orange

	"111": "#0E0E0E",  # M + Y + C -> BlAck
}

var selected_color: int = -1


func reset() -> void :
	selected_color = -1


func get_selected_color() -> String :
	if (selected_color == -1) :
		return "#fff"
	return CHANNEL_COLORS[selected_color]

func get_color_channel() -> String :
	return CHANNELS[selected_color]

func is_selecting_color() -> bool :
	return selected_color != -1
	
