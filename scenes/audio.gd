extends Node2D

var music_tracks = [load("res://audio/asj_3_plain_plains.mp3"), load("res://audio/asj_3_cloud_cloud.mp3"), load("res://audio/asj_3_night_night.mp3")]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func play_music(sound):
	var track = music_tracks[sound]
	if Music.stream != track:
		Music.stream = track 
		Music.play()
	
func play_sound(sound_name : String):
	if sound_name == "click":
		$ClickSoundFX.play()
	elif sound_name == "undo":
		$UndoSoundFX.play()
	elif sound_name == "collect":
		$CollectSoundFX.play()
	elif sound_name == "win":
		$WinSoundFX.play()
	elif sound_name == "water":
		$WaterSoundFX.play()
