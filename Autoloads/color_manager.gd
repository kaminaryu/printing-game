extends Node

const CHANNELS: Array[String] = ["c", "m", "y", "k"]
const CHANNEL_COLORS: Array[String] = ["#00FFFF", "#FF00FF", "#FFFF00", "#000000"]

# key = CMYK
const COLOR_GLOSSARY: Dictionary = {
	"000": "#FFFFFF",  # No ink (paper)
	"100": "#00FFFF",  # C
	"010": "#FF00FF",  # M
	"001": "#FFFF00",  # Y

	"200": "#00CCCC",  # C + C
	"300": "#009999",  # C + C + C

	"020": "#CC00CC",  # M + M
	"030": "#990099",  # M + M + M

	"002": "#CCCC00",  # Y + Y
	"003": "#999900",  # Y + Y + Y

	"110": "#8000FF",  # C + M
	"101": "#00FF40",  # C + Y
	"011": "#FF0080",  # M + Y
	"111": "#2B2B2B",  # C + M + Y

	"210": "#2E2EFF",  # C + C + M
	"201": "#00A6A6",  # C + C + Y

	"120": "#8000A6",  # M + M + C
	"021": "#C00000",  # M + M + Y

	"102": "#80FF00",  # Y + Y + C
	"012": "#FF8000",  # Y + Y + M
}

var selected_color: int = -1


func get_selected_color() -> String :
	if (selected_color == -1) :
		return "#fff"
	return CHANNEL_COLORS[selected_color]
