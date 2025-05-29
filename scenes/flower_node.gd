extends AnimatedSprite2D

@export var color = "white"
var collected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func collect_flower():
	collected = true
	play("default")

func reset_flower():
	stop()
	collected = false
	frame = 0
