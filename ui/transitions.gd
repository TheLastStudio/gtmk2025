extends CanvasLayer

@export var duration := .6

signal transit

func transition():
	var tween = get_tree().create_tween()
	tween.tween_property(
		$ColorRect, "color:a", 1.0, duration/2
	).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	transit.emit()
	
	tween = get_tree().create_tween()
	tween.tween_property(
		$ColorRect, "color:a", 0.0, duration/2
	).set_ease(Tween.EASE_IN)
