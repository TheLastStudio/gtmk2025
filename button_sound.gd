extends Node


func reconnect():
	var nodes = get_tree().get_nodes_in_group("buttons")
	for node in nodes:
		if node is BaseButton:
			node.mouse_entered.connect($Hover.play)
			node.pressed.connect($Click.play)
