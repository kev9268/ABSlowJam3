extends Node2D

var cursor : Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cursor = $Cursor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cursor_follow()

func cursor_follow():
	cursor.global_position = get_local_mouse_position()


func play_sound(sound_name : String):
	if sound_name == "click":
		$ClickSoundFX.play()
	elif sound_name == "undo":
		$CollectSoundFX.play()
	elif sound_name == "collect":
		$UndoSoundFX.play()
	elif sound_name == "win":
		$WinSoundFX.play()
	
