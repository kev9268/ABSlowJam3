extends Node2D

var rain_drop_scene : PackedScene = load("res://scenes/rain_drop.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var rain_drop = rain_drop_scene.instantiate()
	rain_drop.global_position.x = randi_range(3, 237)
	add_child(rain_drop)
