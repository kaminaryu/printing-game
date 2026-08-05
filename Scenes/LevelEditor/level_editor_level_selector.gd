extends PanelContainer

@export var level_cards_list: HBoxContainer
var page: int = 0

func _ready() -> void :
	_change_level_cards()


func _change_level_cards() -> void :
	var num_of_cards: int = level_cards_list.get_child_count()

	for card in level_cards_list.get_children() :
		var level_num: int = page * num_of_cards + card.get_index() + 1
		card.generate_card(level_num)	


func _on_left_button_up() -> void:
	if (page <= 0) : return

	page += -1
	_change_level_cards()


func _on_right_button_up() -> void:
	page += 1
	_change_level_cards()
