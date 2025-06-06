extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


	
func play_sound(sound_name : String):
	if sound_name == "click":
		$ClickSoundFX.play()
	elif sound_name == "undo":
		$UndoSoundFX.play()
	elif sound_name == "collect":
		$CollectSoundFX.play()
	elif sound_name == "win":
		$WinSoundFX.play()
