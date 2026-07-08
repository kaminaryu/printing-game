extends AudioStreamPlayer

@export var sounds: Array[AudioStream]
@export var min_interval := 4.0
@export var max_interval := 15.0

func _ready():
	_play_random_loop()

func _play_random_loop() -> void:
	while true:
		await get_tree().create_timer(randf_range(min_interval, max_interval)).timeout

		if sounds.is_empty():
			continue

		stream = sounds.pick_random()
		pitch_scale = randf_range(0.9, 1.1)
		play()

		# Wait until the sound finishes before starting the next interval.
		await finished
