extends PanelContainer

@export var preview_grid: Control
@export var level_num_label: Label
@export var level_name_label: Label
@export var ink_used_values: Label

func generate_card(level_num: int) -> void :
	var level_data: LevelData = GameMaster.fetch_level_data(level_num)

	if level_data :
		preview_grid.generate_preview(level_num)

		level_num_label.text = "(%d)" % level_num
		level_name_label.text = level_data.level_name

		ink_used_values.text = "%d, %d, %d, %d" % level_data.amount_of_ink_used_cmyk
