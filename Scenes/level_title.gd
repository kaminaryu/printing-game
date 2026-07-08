extends Label

@export var text_speed := 0.07
@export var wait_time := 1.5

@onready var timer = $"../Timer"
@onready var timer_anim = $"../Timer/AnimationPlayer"

func _ready():
	timer.visible = false
	
func title_in():
	await _animate_characters(text.length())

func title_out():
	await _animate_characters(0)

func _animate_characters(target: int):
	while visible_characters != target:
		if visible_characters < target:
			visible_characters += 1
		else:
			visible_characters -= 1

		await get_tree().create_timer(text_speed).timeout
		
func play_animation():
	timer.visible = false
	await title_in()
	await get_tree().create_timer(wait_time).timeout
	await title_out()
	timer_anim.play("Timer In")
	timer.visible = true
