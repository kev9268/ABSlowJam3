extends Sprite2D

@export var branch_count : int = 1000
@export var draw_limit : int = 10000
var draw_count : int 

var debug = false

func _ready() -> void:
	global_position += Vector2(0.5,0.5)
	draw_count = draw_limit
	if not debug:
		self_modulate = Color.TRANSPARENT
	update_text()

func update_text():
	$RichTextLabel.text = "[center]" + str(branch_count)# + ":" + str(draw_count)
