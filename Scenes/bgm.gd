extends AudioStreamPlayer

# 🎵 1. Drag and drop your 5 audio files from the FileSystem into this array in the Inspector
@export var playlist: Array[AudioStream] = []

var shuffled_playlist: Array[AudioStream] = []
var last_played_track: AudioStream = null

func _ready() -> void:
	# If you forgot to load tracks in the inspector, stop here so the game doesn't crash
	if playlist.is_empty():
		push_error("BGM Player: Your playlist array is empty! Please add audio tracks.")
		return
		
	# 🤝 2. Connect Godot's built-in signal that fires the exact millisecond a song ends
	finished.connect(_on_song_finished)
	
	# 🚀 3. Start the initial music machine!
	play_next_random_track()

func play_next_random_track() -> void:
	# If our running shuffled playlist runs out of songs, regenerate and reshuffle it
	if shuffled_playlist.is_empty():
		shuffled_playlist = playlist.duplicate()
		shuffled_playlist.shuffle()
		
		# Preventative Check: If the first song of the newly shuffled list is the exact
		# same as the song that just ended, swap it to the end so it doesn't repeat back-to-back
		if shuffled_playlist.size() > 1 and shuffled_playlist[0] == last_played_track:
			var duplicate_track = shuffled_playlist.pop_front()
			shuffled_playlist.append(duplicate_track)

	# Pull the next track off the top of our shuffled stack
	var next_track = shuffled_playlist.pop_front()
	
	# Assign it to the stream player, save it as history, and hit play!
	stream = next_track
	last_played_track = next_track
	play()
	
	print("Now playing track: ", next_track.resource_path.get_file())

func _on_song_finished() -> void:
	# The moment a track stops playing naturally, this loops to fetch the next one
	play_next_random_track()
