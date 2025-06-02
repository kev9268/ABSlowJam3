extends AnimatedSprite2D

var collectable_type = "flower"
var collect_types = ["leaf","flower","apple","orange","cherry","lemon"]
var collected = false
var original_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = global_position
	animation = collectable_type
	if collectable_type == "leaf":
		offset += Vector2(0, 2)


func collect_item():
	collected = true
	play()

func reset_item():
	stop()
	collected = false
	frame = 0
	global_position = original_position
