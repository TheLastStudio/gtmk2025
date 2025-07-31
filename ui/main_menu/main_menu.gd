extends CanvasLayer
class_name MainMenu


func _on_start_pressed() -> void:
	get_tree().get_first_node_in_group("main").start_game()
