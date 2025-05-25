extends TileMapLayer

var tree_children
var current_tree = null
var draw_flag = true
var set_draw_counter = 200
var draw_counter = set_draw_counter

var previous_mouse_position = Vector2(0,0)
var draw_history = []
var branch_counter = 5

var surround_21 = [
					Vector2i(-2,-1),Vector2i(-2,0),Vector2i(-2,1),
	Vector2i(-1,-2),Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(-1,2),
	Vector2i(0,-2),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(0,2),
	Vector2i(1,-2),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1),Vector2i(1,2),
					Vector2i(2,-1),Vector2i(2,0),Vector2i(2,1),]
var surround_eight = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
					#brown         #green        #orange          #pink
var tree_colors = [Vector2i(0,0),Vector2i(0,1),Vector2i(1,0),Vector2i(1,1)]
var direction_to_vector = {
	"north": Vector2i(0,-1),
	"northeast":Vector2i(1,-1),
	"east":Vector2i(1,0),
	"southeast":Vector2i(1,1),
	"south":Vector2i(0,1),
	"southwest":Vector2i(-1,1),
	"west":Vector2i(-1,0),
	"northwest":Vector2i(-1,-1),
	"none":Vector2i(0,0),
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree_children = get_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if undo_pressed():
		return
	elif Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return

	var mouse_pos = get_local_mouse_position()
	print(draw_counter)
	
	if branch_counter>0:
		click_first(mouse_pos)
		click_held(mouse_pos)	
		click_released()
	else:
		print("no more branches") # temporary probably want to show restart / undo ui when no branches will create issue

	previous_mouse_position = mouse_pos



func add_history():
	#store the draw click, for undo
	var interactions = {}
	for used_position in get_used_cells():
		interactions[used_position] = get_cell_atlas_coords(used_position)
	draw_history.append(interactions)
	
func click_first(mouse_pos):
	if Input.is_action_just_pressed("draw"): #pick tree color for the first time
		current_tree = null
		var new_position = local_to_map(mouse_pos)
		for adj_position in surround_21: #check if valid position
			if(get_cell_source_id(adj_position+new_position) != -1):
				current_tree = get_cell_atlas_coords(adj_position+new_position)
				add_history()
				break
				
func click_held(mouse_pos):
	if Input.is_action_pressed("draw"): #draw the color
		if(current_tree != null):
			var new_position = local_to_map(mouse_pos)
			for adj_position in surround_21:
				if(get_cell_source_id(adj_position+new_position) != -1):
					if get_cell_atlas_coords(new_position+adj_position) == current_tree:
						if (draw_flag):
							make_branch(new_position)
							break
		if draw_counter<0:
			draw_flag= false
			
func click_released():
	if Input.is_action_just_released("draw"):
		draw_flag= true
		branch_counter-=1
		draw_counter = set_draw_counter


func undo_pressed():
	if Input.is_action_just_pressed("undo"):
		if draw_history.size() > 0:
			var world_state = draw_history.pop_back()
			clear()
			for used_position in world_state.keys():
				set_cell(used_position, 0, world_state[used_position])

func make_branch(new_position):
	var collide_position = null
	for adj_position in surround_eight:
		var new_coords = adj_position+new_position
		if get_cell_source_id(new_coords)  != -1 and get_cell_atlas_coords(new_coords) != current_tree: #check collision
			collide_position = new_coords
		else:
			if (new_position != local_to_map(previous_mouse_position)):
				draw_counter-=1
				set_cell(new_coords, 0, current_tree)

	if(collide_position != null):
		var push_position = direction_to_vector[calculate_mouse_direction()]
		move_selected_cells(flood_select(collide_position), push_position)
		
		
func move_selected_cells(list_of_cells, offset):
	var tree_color = get_cell_atlas_coords(list_of_cells[0])
	for cell in list_of_cells: #clear the cells
		var move_next = get_cell_atlas_coords(cell+offset)
		if(move_next != Vector2i(-1,-1) and move_next != tree_color):
			return
	for cell in list_of_cells:
		set_cell(cell)
	for cell in list_of_cells:
		
		set_cell(cell+offset, 0, tree_color)
		
var octants = [PI/8, (3*PI)/8, (5*PI)/8, (7*PI)/8]
func calculate_mouse_direction():
	var mouse_pos = get_local_mouse_position()

	var distance = mouse_pos - previous_mouse_position

	if(distance == Vector2(0,0)):
		return "none"
	var direction = distance.angle()
	if(direction < octants[0] and direction > -octants[0]):
		direction = "east"
	elif(direction < octants[1] and direction > octants[0]):
		direction = "southeast"
	elif(direction < octants[2] and direction > octants[1]):
		direction = "south"
	elif(direction < octants[3] and direction > octants[2]):
		direction = "southwest"
	elif(direction < -octants[0] and direction > -octants[1]):
		direction = "northeast"
	elif(direction < -octants[1] and direction > -octants[2]):
		direction = "north"
	elif(direction < -octants[2]  and direction > -octants[3]):
		direction = "northwest"
	elif(direction < -octants[3]  or direction > octants[3]):
		direction = "west"

	return direction
	
#returns all adjacent cells to pivot_position
func flood_select(pivot_position):
	if(get_cell_source_id(pivot_position) == -1): return []
	
	var tree_color = get_cell_atlas_coords(pivot_position)
	
	var flood_cells = [pivot_position]
	var search_list = {}
	var visited_list = {pivot_position : null}
	
	for initial_position in get_surrounding_cells(pivot_position):
		search_list[initial_position] = null
		
	while search_list.size() > 0:
		var current_position = search_list.keys()[0]
		if get_cell_source_id(current_position) != -1 and get_cell_atlas_coords(current_position) == tree_color:
			flood_cells.append(current_position)
			
			for next_position in get_surrounding_cells(current_position):
				if not next_position in visited_list.keys():
					search_list[next_position] = null
				
		search_list.erase(current_position)
		visited_list[current_position] = null
	return flood_cells
