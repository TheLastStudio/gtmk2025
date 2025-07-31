extends CanvasLayer
class_name MainMenu


func _on_start_pressed() -> void:
	get_tree().get_first_node_in_group("main").start_game()


func _on_settings_pressed() -> void:
	var main = get_tree().get_first_node_in_group("main")
	main.transitions.transition()
	await main.transitions.transit
	$Menu.hide()
	$Settings.show()


func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value/100)


func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value/100)


func _on_back_pressed() -> void:
	var main = get_tree().get_first_node_in_group("main")
	main.transitions.transition()
	await main.transitions.transit
	$Settings.hide()
	$Menu.show()
