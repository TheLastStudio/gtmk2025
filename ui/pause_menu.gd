extends Control


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused: resume()
		else: pause()


func restart() -> void:
	get_tree().paused = false
	get_tree().get_first_node_in_group("game").on_exit_timer = true
	get_tree().get_first_node_in_group("main").restart()


func quit() -> void:
	get_tree().paused = false
	get_tree().get_first_node_in_group("game").on_exit_timer = true
	get_tree().get_first_node_in_group("main").to_menu()


func resume() -> void:
	get_tree().paused = false
	hide()


func pause() -> void:
	get_tree().paused = true
	show()
