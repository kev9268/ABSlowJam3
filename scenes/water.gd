extends TileMapLayer

var surround_eight = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
var tree_tileset : TileMapLayer = null
var water_tileset: TileMapLayer = null
var waters = null

func _ready() -> void:
	tree_tileset = get_node("../Tree")
	water_tileset = get_node("../Water")
	
	
func _process(delta: float) -> void:
	waters = water_tileset.get_used_cells() #water not moving (yet), better to put here
	#var i = 0
	for water in waters:
		for adj_position in surround_eight:
			var check_cell = tree_tileset.get_cell_source_id(adj_position+water)
			if(check_cell == tree_tileset.data_types["root"]):
				var root_node = tree_tileset.find_root_in_current_stroke(water) #this function is similar to the mouse one but works during the mouse draw
				print(root_node)
				if (root_node!=null):
					tree_tileset.add_branch_count(root_node,1) 
					tree_tileset.collect_water(water, root_node)
					print(water_tileset)
					water_tileset.set_cell(water, -1)
					break
				
		#i+=1
