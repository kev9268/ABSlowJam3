extends TileMapLayer

var surround_eight = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
var tree_tileset : TileMapLayer = null
var water_tileset: TileMapLayer = null
var waters = null
var water_scene : PackedScene = load("res://scenes/water.tscn")
var moving_waters = Dictionary()
var all_water_nodes = []

func _ready() -> void:
	tree_tileset = get_node("../Tree")
	water_tileset = get_node("../Water")
	waters = water_tileset.get_used_cells()
	
	#initializaing moving waters
	for water in waters:
		var move_flag = water_tileset.get_cell_tile_data(water).get_custom_data("Move")
		
		var ref = water_scene.instantiate()
		print(ref)
		ref.original_position = water
		ref.current_position = water
		ref.distance = 50 # need to make it check for off screen
		if(move_flag):
			ref.moving = true
			moving_waters[ref] = ref
		all_water_nodes.append(ref)
		$WaterData.add_child(ref)
		
			
func _process(delta: float) -> void:
	waters = water_tileset.get_used_cells() #water not moving (yet), better to put here
	
	#Move cell of moving water
	for pos in moving_waters:
		var droplet = moving_waters[pos]
		if (not droplet.touched):
			water_tileset.set_cell(droplet.current_position,-1)
			if (abs(abs(droplet.original_position.y)-abs(droplet.current_position.y))>droplet.distance):
				droplet.current_position = droplet.original_position
			droplet.current_position = droplet.current_position+Vector2i(0,1) 
			water_tileset.set_cell(droplet.current_position,1,Vector2(0,0))
		
	for water_node in all_water_nodes:
		var water_position = water_node.current_position
		if water_node.touched: continue
		for adj_position in surround_eight:
			var check_cell = tree_tileset.get_cell_source_id(adj_position+water_position)
			if(check_cell == tree_tileset.data_types["root"]):
				var root_node = tree_tileset.find_root_in_current_stroke(water_position) #this function is similar to the mouse one but works during the mouse draw
				if (root_node == null):
					root_node = tree_tileset.find_root_near_mouse(water_position)
				#var tile_id = water_tileset.get_cell_source_id(water)
				print(root_node)
				if (root_node!=null):
					#for ref in moving_waters: #deletes moving water
					#if (water_node in moving_waters.keys() and moving_waters[water_node].current_position == water_position):
					water_node.touched = true
							
					tree_tileset.add_branch_count(root_node,1) 
					tree_tileset.collect_water(water_position, water_node, root_node)
					print(water_tileset)
					water_tileset.set_cell(water_position, -1)
					break
				
