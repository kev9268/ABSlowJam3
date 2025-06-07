extends Node2D

var level_list = [
	"res://scenes/test_level.tscn",
	"res://scenes/levels/image_level/template_level.tscn",
]
var max_screen = 240
var moving = "none"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving == "up":
		if $Scene.global_position.y-135 > -240:
			$Scene.global_position.y -= 1
	if moving == "down":
		if $Scene.global_position.y < 0:
			$Scene.global_position.y += 1


func change_level(level_num : int):
	get_tree().change_scene_to_file(level_list[level_num])
	




func _on_scroll_up_button_down() -> void:
	moving = "down"


func _on_scroll_up_button_up() -> void:
	moving = "none"



func _on_scroll_down_button_down() -> void:
	moving = "up"


func _on_scroll_down_button_up() -> void:
	moving = "none"
