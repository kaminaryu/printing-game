extends Control

@onready var level_card_scene = preload("res://Scenes/LevelSelector/level_card.tscn")


func _ready() -> void :
	_display_card()
	GameMaster.level_increased.connect(_display_card)
	GameMaster.level_decreased.connect(_display_card)


func _display_card() -> void :
	var level_card: Node = level_card_scene.instantiate()
	var level: LevelData = _load_level_by_number(GameMaster.current_level_num)

	if (level == null) :
		printerr("Level doesnt exist mf")
		return 

	level_card.init(level)
	add_child(level_card)



func _load_level_by_number(level_num: int) : 
	var path: String = "res://Resources/Levels/%d.tres" % level_num
	
	if ResourceLoader.exists(path):
		var loaded_resource = load(path) as LevelData
		if loaded_resource:
			
			return loaded_resource

	return null
