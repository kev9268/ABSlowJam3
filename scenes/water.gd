extends TileMapLayer

var surround_eight = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
var tree_tileset : TileMapLayer = null
var water_tileset: TileMapLayer = null
var waters = null
var water_scene : PackedScene = load("res://scenes/water.tscn")
var moving_waters = Dictionary()

func _ready() -> void:
	tree_tileset = get_node("../Tree")
	water_tileset = get_node("../Water")
	waters = water_tileset.get_used_cells()
	
	#initializaing moving waters
	for water in waters:
		var move_flag = water_tileset.get_cell_tile_data(water).get_custom_data("Move")
		if(move_flag):			
			var ref = water_scene.instantiate()
			print(ref)
			ref.original_position = water
			ref.current_position = water
			ref.distance = 50 # need to make it check for off screen
			$WaterData.add_child(ref)
			moving_waters[ref] = ref
			
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
		
	for water in waters:
		var root_node = tree_tileset.find_root_in_current_stroke(water) #this function is similar to the mouse one but works during the mouse draw
		var tile_id = water_tileset.get_cell_source_id(water)
			
		if (root_node!=null):
			for ref in moving_waters: #deletes moving water
				if (moving_waters[ref].current_position == water+Vector2i(0,1)):
					moving_waters[ref].touched = true
			
			tree_tileset.add_branch_count(root_node,1) 
			tree_tileset.collect_water(water, root_node)
			#print(water_tileset)
			water_tileset.set_cell(water, -1)
			break
