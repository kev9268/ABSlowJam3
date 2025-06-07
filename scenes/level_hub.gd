extends Node2D

var level_list = [
	"res://scenes/test_level.tscn",
	"res://scenes/levels/image_level/template_level.tscn",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_level(level_num : int):
	get_tree().change_scene_to_file(level_list[level_num])
	
