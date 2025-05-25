extends TileMapLayer

var tree_children
var current_tree = null
var draw_flag = true
var set_draw_counter = 200
var draw_counter = set_draw_counter
var old_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree_children = get_children()

var tree_colors = [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,1)]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	print(draw_counter)
	if Input.is_action_just_pressed("draw"): #pick tree color for the first time
		current_tree = null
		var new_position = local_to_map(mouse_pos)
		for adj_position in surround_21:
			if(get_cell_source_id(adj_position+new_position) != -1):
				current_tree = get_cell_atlas_coords(adj_position+new_position)
				break
				
	if Input.is_action_pressed("draw"): #draw the color
		if(current_tree != null):
			var new_position = local_to_map(mouse_pos)
			for adj_position in surround_21:
				if(get_cell_source_id(adj_position+new_position) != -1):
					if (draw_flag):
						make_branch(new_position,old_position)
					break
		if draw_counter<0:
			draw_flag= false
	else:
		draw_flag= true
		draw_counter = set_draw_counter
		
	old_position = local_to_map(mouse_pos)

var surround_21 = [
					Vector2i(-2,-1),Vector2i(-2,0),Vector2i(-2,1),
	Vector2i(-1,-2),Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(-1,2),
	Vector2i(0,-2),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),
	Vector2i(1,-2),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1),Vector2i(1,2),
					Vector2i(2,-1),Vector2i(2,0),Vector2i(2,1),]
var surround_eight = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
func make_branch(new_position, old_position):
	for adj_position in surround_eight:
		if (new_position != old_position):
			draw_counter-=1
			set_cell(adj_position+new_position, 0, current_tree)
	
