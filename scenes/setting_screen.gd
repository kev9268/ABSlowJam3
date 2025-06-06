extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _done_button_pressed():
	visible = false

func _on_master_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
	
func _on_music_slider_value_changed(value: float) -> void:
	pass # Replace with function body.

func _on_effects_slider_value_changed(value: float) -> void:
	pass # Replace with function body.

func _on_background_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
