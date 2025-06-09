extends Button

@export var level_id : String
@export var unlocks : Array[NodePath] = []
var true_visible = false
var complete_tile = load("res://scenes/level_tile_complete.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var complete = Global.level_list.has(level_id)

	for node in unlocks:
		if not complete and Global.dev_mode == false:
			if not true_visible:
				get_node(node).visible = false
		else:
			true_visible = true
				
	if complete:
		add_theme_color_override("font_color", Color.BLACK)
		add_theme_stylebox_override("hover", complete_tile)
		add_theme_stylebox_override("normal", complete_tile)
		add_theme_stylebox_override("pressed", complete_tile)
		add_theme_stylebox_override("hover_pressed", complete_tile)

func _on_pressed() -> void:
	Global.player_data["previous_scene"] = Global.player_data["current_scene"]
	Global.player_data["current_scene"] = level_id
	get_tree().change_scene_to_file("res://scenes/levels/"+level_id+"/level.tscn")
