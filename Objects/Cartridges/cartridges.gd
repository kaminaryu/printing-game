extends Node

@onready var cartridges = {
	"c": $CyanCartridge,
	"m": $MagentaCartridge,
	"y": $YellowCartridge,
	"k": $KeyCartridge
}

func _ready() -> void:
	ColorManager.selected_color = -1

func update_visible_channels(level_data: LevelData) -> void:
	var allowed_channels: Array = level_data.available_channels
	
	for channel in cartridges.keys():
		if cartridges[channel]:
			cartridges[channel].visible = allowed_channels.has(channel)

func update_ink_label(channel: String, remaining_count: int) -> void:
	if cartridges.has(channel) and cartridges[channel]:
		cartridges[channel].update_ink(remaining_count)
