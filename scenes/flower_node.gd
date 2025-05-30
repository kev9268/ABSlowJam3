extends AnimatedSprite2D

@export var color = "white"
var collected = false
var original_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = global_position


func collect_flower():
	collected = true
	play("default")

func reset_flower():
	stop()
	collected = false
	frame = 0
	global_position = original_position
