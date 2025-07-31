extends Line2D

@export var max_length := 16
var queue: Array


func _process(_delta: float) -> void:
	var pos = get_parent().global_position
	
	queue.push_front(pos)
	
	if queue.size() > max_length:
		queue.pop_back()
	
	clear_points()
	for point in queue:
			add_point(point)
