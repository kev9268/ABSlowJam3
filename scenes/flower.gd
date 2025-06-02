extends TileMapLayer

var surround_eight = [Vector2i(-1,-1),Vector2i(-1,0),Vector2i(-1,1),Vector2i(0,-1),Vector2i(0,0),Vector2i(0,1),Vector2i(1,-1),Vector2i(1,0),Vector2i(1,1)]
var pos = Vector2i(0,0)
var tree_tileset : TileMapLayer = null
var buds = null
#.get_node("Layers/Tree")
var flower_scene : PackedScene = load("res://scenes/flower.tscn")

var tile_types = {
	"tree":0,
	"wall":1,
}

var flower_data = {}

func _ready() -> void:
	tree_tileset = get_node("../Tree")
	buds = get_used_cells()
	
	for bud in buds:
		var flower_node = flower_scene.instantiate()
		flower_node.collectable_type = flower_node.collect_types[get_cell_source_id(bud)]
		flower_node.global_position = bud
		flower_data[bud] = flower_node
		$FlowerData.add_child(flower_node)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var i = 0
	for bud in buds:
		if flower_data[bud].collected: continue
		for adj_position in surround_eight:
			var check_cell = tree_tileset.get_cell_source_id(adj_position+bud)
			if(check_cell == tile_types["tree"]):
				var success = tree_tileset.collect_flower(bud, flower_data[bud], check_cell)
				if success:
					flower_data[bud].collect_item()
				#print("blossom " + str(i))
				break
			#else:
				#print("nothing " + str(i))
		i+=1
		
			

		
	
	
