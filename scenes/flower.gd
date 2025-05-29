extends TileMapLayer

var surround_eight = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
var pos = Vector2i(0,0)
var tree_tileset = null
var buds = null
#.get_node("Layers/Tree")

var tile_types = {
	"tree":0,
	"wall":1,
}

func _ready() -> void:
	tree_tileset = get_node("../Tree")
	buds = get_used_cells()
	print(buds)
	print(tree_tileset)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var i = 0
	for bud in buds:
		
		for adj_position in surround_eight:
			var check_cell = tree_tileset.get_cell_source_id(adj_position+bud)
			if(check_cell != -1 and check_cell == tile_types["tree"]):
				print("blossom " + str(i))
				break
			else:
				print("nothing " + str(i))
		i+=1
		
			

		
	
	
