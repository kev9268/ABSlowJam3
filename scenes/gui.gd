extends CanvasLayer

@export var is_title_screen = false

var scenes = {
	"title" : "res://scenes/title_screen.tscn",
	"hub" : "res://scenes/level_hub.tscn",
	
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_title_screen:
		$TitleScreen.visible = true
	if Global.player_data["current_scene"] == "hub" and Global.just_completed:
		Global.just_completed = false
		$CompleteScreen.play_fade()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.s
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause_menu()
		
func toggle_pause_menu():
	$SettingScreen._done_button_pressed()
	if $PauseMenu.visible:
		close_pause_menu()
	else:
		open_pause_menu()

func close_pause_menu():
	Global.paused = false
	$PauseMenu.visible = false
	
func open_pause_menu():
	Global.paused = true
	$PauseMenu.visible = true

func toggle_setting_screen():
	$SettingScreen.settings_button_pressed()

func switch_scene(scene_name : String):
	Global.player_data["previous_scene"] = Global.player_data["current_scene"]
	Global.player_data["current_scene"] = scene_name
	get_tree().change_scene_to_file(scenes[scene_name])
	
func return_level():
	if Global.player_data["current_scene"] == "hub":
		Global.player_data["previous_scene"] = "hub"
		Global.player_data["current_scene"] = "title"
		get_tree().change_scene_to_file(scenes["title"])
	else:
		Global.player_data["previous_scene"] = Global.player_data["current_scene"]
		Global.player_data["current_scene"] = "hub"
		get_tree().change_scene_to_file(scenes["hub"])
	
func restart_scene():
	get_tree().reload_current_scene()

func finish_level():
	$CompleteScreen.play_complete()

func _on_complete_screen_animation_complete() -> void:
	Global.paused = false
	Global.player_data["previous_scene"] = Global.player_data["current_scene"]
	Global.player_data["current_scene"] = "hub"
	get_tree().change_scene_to_file(scenes["hub"])


func _on_dev_mode_pressed() -> void:
	Global.dev_mode = !Global.dev_mode
	switch_scene("hub")
