extends Node2D


func _physics_process(delta: float) -> void:
	scale.x += delta*5.5
	scale.y += delta*5.5
	$CollectingIndicator.modulate.a -= delta/2
	if $CollectingIndicator.modulate.a < 0:
		queue_free()
