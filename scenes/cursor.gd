extends Sprite2D

var previous_direction = Vector2.ZERO
func text_offset(direction):

	if direction != Vector2.ZERO and previous_direction != direction:
		var tween = get_tree().create_tween()
		tween.tween_property($TextPivot, "position", (-direction * 20), 0.1).set_ease(Tween.EASE_OUT)
		#tween.finished.connect(set_new_position, (direction * 15) + position)
		tween.play()
		previous_direction = direction

func set_text(text):
	$TextPivot/RichTextLabel.text = "[center]" + str(text)
