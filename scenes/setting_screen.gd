extends Control

var off_screen = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_all()

func update_all():
	update_slider()
	update_text()
	
func update_slider():
	$RightSide/Music/HSlider.value = Global.player_data["music"]
	$RightSide/Master/HSlider.value = Global.player_data["audio"]
	$RightSide/Effects/HSlider.value = Global.player_data["effects"]
	$LeftSide/Background/HSlider.value = Global.player_data["background_transparency"]
	
	
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), Global.player_data["audio"]/100.0)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), Global.player_data["music"]/100.0)
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Sound Effects"), Global.player_data["effects"]/100.0)
	
	
func update_text():
	$RightSide/Music/RichTextLabel.text = "[center]Music " + str(int($RightSide/Music/HSlider.value)) + "%"
	$RightSide/Master/RichTextLabel.text = "[center]Audio " + str(int($RightSide/Master/HSlider.value)) + "%"
	$RightSide/Effects/RichTextLabel.text = "[center]Effects " + str(int($RightSide/Effects/HSlider.value)) + "%"
	$LeftSide/Background/RichTextLabel.text = "[center]Background " + str(int($LeftSide/Background/HSlider.value)) + "%"

func settings_button_pressed():
	if off_screen and not $AnimationPlayer.is_playing():
		off_screen = false
		$AnimationPlayer.play("enter")

func _done_button_pressed():
	if not off_screen and not $AnimationPlayer.is_playing():
		off_screen = true
		$AnimationPlayer.play("exit")

func _on_master_slider_value_changed(value: float) -> void:
	Global.player_data["audio"] = value
	update_all()
	
func _on_music_slider_value_changed(value: float) -> void:
	Global.player_data["music"] = value
	update_all()

func _on_effects_slider_value_changed(value: float) -> void:
	Global.player_data["effects"] = value
	update_all()

func _on_background_slider_value_changed(value: float) -> void:
	Global.player_data["background_transparency"] = value
	update_all()
