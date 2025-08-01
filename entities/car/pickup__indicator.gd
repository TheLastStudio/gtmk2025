extends Node2D


func _physics_process(delta: float) -> void:
	scale.x += delta*3
	scale.y += delta*3
	$CollectingIndicator.modulate.a -= delta/2
