extends AnimatedSprite2D

var original_position
var current_position
var touched = false
var distance = 135
var moving = false

func _ready() -> void:
	if(moving): animation = "fall"
	global_position = current_position

func collect_item():
	touched = true
	play("default")

func reset_item():
	stop()
	touched = false
	if(moving): animation = "fall"
	frame = 0
	global_position = current_position
