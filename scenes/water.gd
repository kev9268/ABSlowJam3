extends TileMapLayer

var surround_eight = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
var tree_tileset : TileMapLayer = null
var water_tileset: TileMapLayer = null
var waters = null

func _ready() -> void:
	tree_tileset = get_node("../Tree")
	water_tileset = get_node("../Water")
	
	
func _process(delta: float) -> void:
	var i = 0
	waters = water_tileset.get_used_cells()
	for water in waters:
		for adj_position in surround_eight:
			var check_cell = tree_tileset.get_cell_source_id(adj_position+water)
			if(check_cell == tree_tileset.data_types["root"]):
				var root_node = tree_tileset.find_root_near_mouse(water)
				print(root_node)
				if (root_node!=null):
					tree_tileset.add_branch_count(root_node,1) 
					print(water_tileset)
					water_tileset.set_cell(water, -1)
					break
				
		i+=1
