extends TileMapLayer

var tree_children
var current_root = null
var recent_pushed_root = null
var draw_flag = true
var branch_flag = false # Flag that checks if a branch is successfully being drawn

var mech_types = {
	"fire":0,
	"dark":1,
	"break":2,
	"wall":3,
}
var data_types = {
	"root":0
}

var previous_mouse_position = Vector2(0,0)
var draw_history = []
var first_click = false


var previous_color = Vector2i(-1,-1)
var stored_pixel_limit = 30
var current_stroke_pixels = []

var mechanic_layer : TileMapLayer

var cursor : Sprite2D

#not 25 because those 4 corners are not diagonal attached
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
var fruit_to_tree = {
	"apple": Vector2i(0,0),
	"orange": Vector2i(0,1),
	"lemon": Vector2i(1,0),
	"cherry": Vector2i(1,1),
}

var root_data = {}
var history_collected = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree_children = get_children()
	scan_for_tree_group(true)
	mechanic_layer = get_node("../Mechanics")
	#draw_branch_line(Vector2(5,106), Vector2(63,123))


func scan_for_tree_group(initialize = false):
	for root_node : Sprite2D in get_node("RootData").get_children():
		var root_position = local_to_map(root_node.global_position)
		
		if(initialize):
			root_data[root_node.name] = {
				"tree_group" : flood_select(root_position, true),
				"tree_color" : get_cell_atlas_coords(root_position),
				"node" : root_node,
				"collection" : {},
			}
		else:
			root_data[root_node.name]["tree_group"] = flood_select(root_position, true)
			root_data[root_node.name]["tree_color"] = get_cell_atlas_coords(root_position)
			root_data[root_node.name]["node"] = root_node



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if undo_pressed():
		return
	elif Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return

	var mouse_pos = get_local_mouse_position()
	
	if current_root == null:
		var found_root = find_root_near_mouse(mouse_pos)
		if(found_root != null):
			mouse_highlight(true)
			if get_branch_count(found_root) > 0:
				click_first(mouse_pos, found_root)
			else:
				mouse_highlight(false)
				print("no more branches") # temporary probably want to show restart / undo ui when no branches will create issue
		else:
			mouse_highlight(false)
	else:
		click_held(mouse_pos)
		click_released()


	previous_mouse_position = mouse_pos

func find_root_near_mouse(mouse_pos):
	var new_position = local_to_map(mouse_pos)
	for adj_position in surround_21: #check if valid position
		var adjacent_position = adj_position+new_position
		var check_cell = get_cell_source_id(adjacent_position)
		if(check_cell != -1):
			var found_root = search_for_root(adjacent_position)
			if(found_root != null):
				return found_root
	return null
	
func find_root_in_current_stroke(current_position):
	var root_name = null
	for stroke_pixel in current_stroke_pixels:
		if current_position == stroke_pixel:
			root_name = current_root
			break
	if(root_name == null):
		if(recent_pushed_root != null):
			root_name = recent_pushed_root
			
	return root_name

func mouse_highlight(active):
	if active:
		get_parent().get_parent().cursor.modulate = Color(1.0,1.0,1.0,0.5)
	else:
		get_parent().get_parent().cursor.modulate = Color(1.0,1.0,1.0,0.0)
	
func click_first(mouse_pos, found_root):
	if Input.is_action_just_pressed("draw"): #pick tree color for the first time
		current_root = found_root
		if current_root != null:
			add_history()
		first_click = true
				
func click_held(mouse_pos):
	if Input.is_action_pressed("draw"): #draw the color
		
		if get_draw_count(current_root) < 0:
			draw_flag = false
			return 
		#drawing smoother
		#get distance
		#draw_branch_line(previous_mouse_position, mouse_pos)
		#return
		var distance = mouse_pos - previous_mouse_position
		var step = max(abs(distance.x), abs(distance.y))
		var offset = 1.0 / step
		var weight = 0 #addition is cheaper
		for stepping in range(0, step+1, 1):
			var interpolated_position = local_to_map(previous_mouse_position.lerp(mouse_pos, weight))
			weight += offset 
			#check if draw on itself in the same stroke or draw on its self at all
			if check_limit(interpolated_position):
				return
			
			for adj_position in surround_21:
				var adjacent_position = adj_position+interpolated_position
				var check_cell = get_cell_source_id(adjacent_position)
				
				if(check_cell != -1): #check if the future draw will be next to the tree color, checks in the 21 different 
					if get_cell_atlas_coords(adjacent_position) == root_data[current_root]["tree_color"]:
						
						if (draw_flag):
							branch_flag = true
							make_branch(interpolated_position)
							break
							
			apply_mechanic()
		
func draw_branch_line(pos1, pos2):
	var distance = pos2 - pos1
	var step = max(abs(distance.x), abs(distance.y))
	for stepping in range(0, step+1, 1):
		var weight = float(stepping) / step
		var interpolated_position = local_to_map(pos2.lerp(pos1, weight))
		#check draw
		for adj_position in surround_eight:
			var new_coords = adj_position+interpolated_position
			set_cell(new_coords, 0, Vector2(0,0))
			
func click_released():
	if Input.is_action_just_released("draw") and branch_flag:
		end_click()
		
func end_click():
	branch_flag = false
	draw_flag = true
	
	if(current_root != null):
		add_branch_count(current_root, -1)
		set_draw_count(current_root, get_draw_limit(current_root))
	
	current_root = null
	recent_pushed_root = null
	previous_color = Vector2i(-1,-1)
	current_stroke_pixels.clear()
	mouse_highlight(false)
	scan_for_tree_group()
	
func check_limit(new_position):
	#check if the mouse is directly over it's current brush section, (make previous branch a wall)
	for i in range(0, current_stroke_pixels.size()-stored_pixel_limit):
		var check_position = current_stroke_pixels[i]
		if (new_position == check_position):
			end_click()
			return true
	#check if the mouse is directly over old branch section, (make previous branch a wall)
	if(current_stroke_pixels.size() >= stored_pixel_limit):
		var root = search_for_root(new_position)

		if (root == current_root):
			end_click()
			return true
			
	return false

func apply_mechanic():
	for cell in mechanic_layer.get_used_cells_by_id(0): #fire tile
		set_cell(cell)
	
func add_history():
	#store the draw click, for undo
	var interactions = {"tree":{}, "break":{}}
	for used_position in get_used_cells():
		interactions["tree"][used_position] = get_cell_atlas_coords(used_position)
	for used_position in mechanic_layer.get_used_cells_by_id(mech_types["break"]):
		interactions["break"][used_position] = mechanic_layer.get_cell_atlas_coords(used_position)
	
	var root_list = []
	for root_node in root_data.keys():
		root_list.append({
			"root" : root_data[root_node]["node"],
			"position" : root_data[root_node]["node"].global_position,
			"branch" : root_data[root_node]["node"].branch_count,
			"collection" : root_data[root_node]["collection"].duplicate(true)
		})
	interactions["roots"] = root_list
	
	draw_history.append(interactions)
	
	

func undo_pressed():
	#force end click in case
	if Input.is_action_just_pressed("undo"):
		end_click()
		if draw_history.size() > 0:

			clear()
			var world_state = draw_history.pop_back()
			
			
			var position_difference = Vector2(0,0)
			for root_node in world_state["roots"]:
				root_node["root"].branch_count = root_node["branch"]
				position_difference = root_node["position"] - root_node["root"].global_position
				root_node["root"].global_position = root_node["position"]
				update_root_display(root_node["root"])
				
				#undo collectables
				for item in root_data[root_node["root"].name]["collection"].keys():
					#check for differences
					var just_added = false
					if not item in root_node["collection"].keys():
						just_added = true
						
					if item is String and item.contains("water"):
						if just_added:
							print("undid")
							get_node("../Water").set_cell(root_data[root_node["root"].name]["collection"][item], 0, Vector2i(0,0))
							root_data[root_node["root"].name]["collection"].erase(item)
					elif item.has_meta("type") and item.get_meta("type") == "flower":
						if just_added:
							item.reset_item()
							root_data[root_node["root"].name]["collection"].erase(item)
						else:
							var old_position = root_node["collection"][item]["position"]
							item.global_position = Vector2(old_position) 
							root_data[root_node["root"].name]["collection"][item]["position"] = old_position
			
			for used_position in world_state["tree"]:
				set_cell(used_position, 0, world_state["tree"][used_position])
			for used_position in world_state["break"]:
				mechanic_layer.set_cell(used_position, mech_types["break"], world_state["break"][used_position])
			
			previous_color = Vector2i(-1,-1)
			scan_for_tree_group()
		return true
	return false

func make_branch(new_position):
	var collide_position = null
	for adj_position in surround_eight:
		var new_coords = adj_position+new_position
		if get_cell_atlas_coords(new_coords) != root_data[current_root]["tree_color"]: #dont draw on self, prevent consumuption
			var check_mech_cell = mechanic_layer.get_cell_source_id(new_coords)
			if check_mech_cell != -1: continue #dont draw over anything in this layer
				
			var check_cell = get_cell_source_id(new_coords)
			if check_cell != -1: #check collision
				if not check_collision_type(new_coords):
					break
			else:
				add_draw_count(current_root, -1)
				update_root_display(root_data[current_root]["node"])
				
				set_cell(new_coords, 0, root_data[current_root]["tree_color"])
				
				current_stroke_pixels.append(new_coords)
			
	first_click = false
		
func check_collision_type(collide_position):

	if(get_cell_source_id(collide_position) == 0): #collision is a tree, push it
		var push_position = direction_to_vector[calculate_mouse_direction()]
		var flood_info = flood_select(collide_position, false, true)
		if(flood_info[0].size() > 0):
			recent_pushed_root = flood_info[0][0]
		if(move_selected_cells(flood_info[1], push_position)):
			move_attachments(flood_info[0], push_position)
			return true
	return false
		
		
func move_selected_cells(list_of_cells, offset):

	var tree_color = get_cell_atlas_coords(list_of_cells[0])
	var breakable_tiles = []
	for cell in list_of_cells: #check the cells
		var next_position = cell+offset
		var move_next = get_cell_atlas_coords(next_position)
		var mech_next = mechanic_layer.get_cell_source_id(next_position)
		if(mech_next == mech_types["wall"] or (move_next != Vector2i(-1,-1) and move_next != tree_color)): #ignore non pushable
			return false
		elif(mech_next == mech_types["break"]):
			breakable_tiles.append(next_position)
				
	for cell in list_of_cells: #clear those old cells
		set_cell(cell)
	for cell in list_of_cells:
		set_cell(cell+offset, 0, tree_color)
	for cell in breakable_tiles:
		mechanic_layer.set_cell(cell)
	return true
	
func move_attachments(roots, offset):
	for root in roots:
		root_data[root]["node"].global_position += Vector2(offset)
		for collection in root_data[root]["collection"].keys():
			collection.global_position += Vector2(offset)
			root_data[root]["collection"][collection]["position"] += local_to_map(offset)
		
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
func flood_select(pivot_position, edge_only = false, find_root = false):
	var cell_id = get_cell_source_id(pivot_position)
	if(cell_id == -1): return []
	
	var tree_color = get_cell_atlas_coords(pivot_position)
	
	var flood_cells = [pivot_position]
	var search_list = {}
	var visited_list = {pivot_position : null}
	var roots_found = []
	
	for initial_position in get_surrounding_cells(pivot_position):
		search_list[initial_position] = null
		
	while search_list.size() > 0:
		var current_position = search_list.keys()[0]
		if get_cell_source_id(current_position) == cell_id and get_cell_atlas_coords(current_position) == tree_color:
			
			if(edge_only == false or not check_adj_is_same(tree_color, current_position)):
				flood_cells.append(current_position)
				if(find_root):
					for root_name in root_data.keys():
						if current_position == local_to_map(root_data[root_name]["node"].global_position):
							roots_found.append(root_name)
			
			for next_position in get_surrounding_cells(current_position):
				if not next_position in visited_list.keys():
					search_list[next_position] = null
				
		search_list.erase(current_position)
		visited_list[current_position] = null
		
	if(find_root):
		return [roots_found, flood_cells]
	return flood_cells
	
func check_adj_is_same(tree_color, current_position):
	for adj_cell in get_surrounding_cells(current_position):
		if(get_cell_atlas_coords(adj_cell) != tree_color):
			return false
	return true
	
func search_for_root(target_position):
	var root_list = []
	for root_name in root_data.keys():
		var root_group = root_data[root_name]["tree_group"]
		if(target_position in root_group):
			if get_branch_count(root_name) > 0:
				root_list.append(root_name)
	var closest_root = null
	for root_name in root_list:
		if closest_root == null:
			closest_root = root_name
		elif root_data[root_name]["node"].global_position.distance_squared_to(target_position) < root_data[closest_root]["node"].global_position.distance_squared_to(target_position):
			closest_root = root_name
	return closest_root
	
func update_root_display(found_root):
	found_root.update_text()

func get_branch_count(found_root):
	if(found_root == null): return -1
	return root_data[found_root]["node"].branch_count

func get_draw_count(root_name):
	return root_data[root_name]["node"].draw_count
	
func get_draw_limit(root_name):
	return root_data[root_name]["node"].draw_limit
	
func add_branch_count(root_name, value):
	root_data[root_name]["node"].branch_count += value
	update_root_display(root_data[root_name]["node"])

func add_draw_count(root_name, value):
	root_data[root_name]["node"].draw_count += value
	update_root_display(root_data[root_name]["node"])
	
func set_draw_count(root_name, value):
	root_data[root_name]["node"].draw_count = value
	update_root_display(root_data[root_name]["node"])
	
func collect_flower(position_collected, flower_node, branch_position):
	var root_name = null
	for adj_position in surround_eight:
		if position_collected+adj_position in current_stroke_pixels:
			root_name = current_root
			if flower_node.collectable_type != "leaf":
				end_click()
			break
	if(root_name == null):
		if(recent_pushed_root != null):
			root_name = recent_pushed_root
		else:
			print("function collect_flower: likely a bug")

	var flower_data = {
		"root" : root_name,
		"position" : position_collected,
	}
	#items_collected[flower_node] = flower_data
	if root_name != null:
		var valid = false
		if fruit_to_tree.has(flower_node.collectable_type):
			if fruit_to_tree[flower_node.collectable_type] == root_data[root_name]["tree_color"]:
				valid = true
		else:
			valid = true
		
				
		if valid:
			root_data[root_name]["collection"][flower_node] = flower_data
			return true
	return false
	
var unique_id = 0
func collect_water(position_collected, root_name):
	if root_name != null:
		print("Added")
		root_data[root_name]["collection"]["water" + str(unique_id)] = position_collected
		unique_id += 1
		return true
	return false
