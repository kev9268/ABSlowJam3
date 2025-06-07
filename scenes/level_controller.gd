class_name Level_Controller
extends Node2D

var cursor : Sprite2D
@export var level_folder : String = ""
@export var music_type : int 

var previous_mouse_position = Vector2(0,0)
var screen_dimensions = Vector2(240,135)
var pixel_to_data = {
	Color.hex(0x411c03ff) : "apple_tree",
	Color.hex(0x553800ff) : "orange_tree",
	Color.hex(0x525200ff) : "lemon_tree",
	Color.hex(0x5f3452ff) : "cherry_tree",
	
	Color.hex(0xff0000ff) : "apple_fruit",
	Color.hex(0xff7f00ff) : "orange_fruit",
	Color.hex(0xffff00ff) : "lemon_fruit",
	Color.hex(0xff007fff) : "cherry_fruit",
	
	Color.hex(0x00ff00ff) : "leaf",
	Color.hex(0xff00ffff) : "flower",
	
	Color.hex(0x2a4b13ff) : "vine_1",
	Color.hex(0x215842ff) : "vine_2",
	
	Color.hex(0xffffffff) : "cloud_1",
	Color.hex(0xcbcbcbff) : "cloud_2",
	
	Color.hex(0xcc0000ff) : "fire_1",
	Color.hex(0xcc3300ff) : "fire_2",
	Color.hex(0xcc6600ff) : "fire_3",
	
	Color.hex(0x00ffffff) : "water",
	Color.hex(0x0000ffff) : "water_fall",
	
	Color.hex(0x000000ff) : "dark",
	
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	cursor = $Cursor
	if level_folder != "":
		var image_path = "res://scenes/levels/" + level_folder
		var tile_data = load(image_path + "/tree_data.png")
		var background = load(image_path + "/background.png") 
		$Background.texture = background
		load_level(tile_data)
	start_level()
	
func start_level():
	$Layers/Tree.initialize()
	$Layers/Collectable.initialize()
	$Layers/Water.initialize()
	$Audio.play_music(music_type)
			
func load_level(image):
	var data = image.get_image()
	var tree_layer : TileMapLayer = $Layers/Tree
	var mech_layer : TileMapLayer = $Layers/Mechanics
	var collect_layer : TileMapLayer = $Layers/Collectable
	var water_layer : TileMapLayer = $Layers/Water
	#data.lock()
	for x in range(0, screen_dimensions.x):
		for y in range(0, screen_dimensions.y):
			var pixel = data.get_pixel(x,y)
			if pixel.a > 0:
				var tile = pixel_to_data[pixel]
				if tile == "apple_tree":
					tree_layer.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
				elif tile == "orange_tree":
					tree_layer.set_cell(Vector2i(x,y), 0, Vector2i(0,1))
				elif tile == "lemon_tree":
					tree_layer.set_cell(Vector2i(x,y), 0, Vector2i(1,0))
				elif tile == "cherry_tree":
					tree_layer.set_cell(Vector2i(x,y), 0, Vector2i(1,1))
				elif tile == "leaf":
					collect_layer.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
				elif tile == "flower":
					collect_layer.set_cell(Vector2i(x,y), 1, Vector2i(0,0))
				elif tile == "apple_fruit":
					collect_layer.set_cell(Vector2i(x,y), 2, Vector2i(0,0))
				elif tile == "orange_fruit":
					collect_layer.set_cell(Vector2i(x,y), 3, Vector2i(0,0))
				elif tile == "cherry_fruit":
					collect_layer.set_cell(Vector2i(x,y), 4, Vector2i(0,0))
				elif tile == "lemon_fruit":
					collect_layer.set_cell(Vector2i(x,y), 5, Vector2i(0,0))
				elif tile == "vine_1":
					mech_layer.set_cell(Vector2i(x,y), 2, Vector2i(1,0))
				elif tile == "vine_2":
					mech_layer.set_cell(Vector2i(x,y), 2, Vector2i(0,0))
				elif tile == "cloud_1":
					mech_layer.set_cell(Vector2i(x,y), 3, Vector2i(0,0))
				elif tile == "cloud_2":
					mech_layer.set_cell(Vector2i(x,y), 3, Vector2i(1,0))
				elif tile == "fire_1":
					mech_layer.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
				elif tile == "fire_2":
					mech_layer.set_cell(Vector2i(x,y), 0, Vector2i(1,0))
				elif tile == "fire_3":
					mech_layer.set_cell(Vector2i(x,y), 0, Vector2i(0,1))
				elif tile == "water":
					water_layer.set_cell(Vector2i(x,y), 0, Vector2i(0,0))
				elif tile == "water_fall":
					water_layer.set_cell(Vector2i(x,y), 1, Vector2i(0,0))
				elif tile == "dark":
					mech_layer.set_cell(Vector2i(x,y), 1, Vector2i(0,0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.paused:
		return
	cursor_follow()
	
func update_cursor_text(text):
	cursor.set_text(text)

func cursor_follow():
	var mouse_position = get_tree().get_root().get_mouse_position()
	cursor.global_position = mouse_position
	var mouse_direction = (mouse_position - previous_mouse_position).normalized()
	var distance = (mouse_position - previous_mouse_position).length_squared() > 0.2
	var direction = Vector2(0,0)
	if distance:
		if mouse_direction.y < 0:
			direction = Vector2(0,-1)
		else:
			direction = Vector2(0,1)
	cursor.text_offset(direction)
	
	previous_mouse_position = mouse_position
	

func play_sound(sound_name : String):
	$Audio.play_sound(sound_name)
	
func complete_level():
	Global.paused = true
	Global.level_list[level_folder] = true
	Global.just_completed = true
	$Audio.play_sound("win")
	$GUI.finish_level()
