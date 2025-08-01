extends Control

var lifetime: float
var seconds_in_loop

var exiting = false

func set_data(_lifetime, _seconds_in_loop):
	lifetime = _lifetime
	seconds_in_loop = _seconds_in_loop
	$VBoxContainer/Lifetime.text = "Loops survived: " + str(snapped(lifetime/seconds_in_loop, 0.05))


func _on_menu_pressed() -> void:
	if exiting: return
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(Dialogic.VAR.name, snapped(lifetime/seconds_in_loop, 0.05)).sw_save_score_complete
	print("Score persisted successfully: " + str(sw_result.score_id))
	$VBoxContainer/MarginContainer/HBoxContainer/Menu.text = "Loading..."
	get_tree().get_first_node_in_group("main").to_menu()


func _on_restart_pressed() -> void:
	if exiting: return
	var sw_result: Dictionary = await SilentWolf.Scores.save_score(Dialogic.VAR.name, snapped(lifetime/seconds_in_loop, 0.05)).sw_save_score_complete
	print("Score persisted successfully: " + str(sw_result.score_id))
	$VBoxContainer/MarginContainer/HBoxContainer/Restart.text = "Loading..."
	get_tree().get_first_node_in_group("main").restart()
