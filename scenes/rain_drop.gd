extends AnimatedSprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(global_position.y >= 132):
		play("default")
	else:
		global_position.y += 1


func _on_animation_finished() -> void:
	queue_free()
