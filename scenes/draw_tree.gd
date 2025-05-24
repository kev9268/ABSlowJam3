extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("draw"):
		print(get_local_mouse_position())
		var new_position = local_to_map(get_local_mouse_position())
		for adj_position in surround_21:
			if(get_cell_source_id(adj_position+new_position) != -1):
				make_branch(new_position)
				break


var surround_21 = [
					Vector2i(-2,-1),Vector2i(-2,0),Vector2i(-2,1),
	Vector2i(-1,-2),Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(-1,2),
	Vector2i(0,-2),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),
	Vector2i(1,-2),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1),Vector2i(1,2),
					Vector2i(2,-1),Vector2i(2,0),Vector2i(2,1),]
var surround_eight = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
func make_branch(new_position):
	for adj_position in surround_eight:
		set_cell(adj_position+new_position, 0, Vector2i(0,0))
	
