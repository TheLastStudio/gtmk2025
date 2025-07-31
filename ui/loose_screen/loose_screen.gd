extends Control

var lifetime: float
var seconds_in_loop


func set_data(_lifetime, _seconds_in_loop):
	lifetime = _lifetime
	seconds_in_loop = _seconds_in_loop
	$Lifetime.text = "Loops survived: " + str(snapped(lifetime/seconds_in_loop, 0.05))


func _on_menu_pressed() -> void:
	var sw_result: Dictionary = await SilentWolf.Scores.save_score("Player"+str(randi_range(100,999)), snapped(lifetime/seconds_in_loop, 0.05)).sw_save_score_complete
	print("Score persisted successfully: " + str(sw_result.score_id))
	
	get_tree().get_first_node_in_group("main").to_menu()


func _on_restart_pressed() -> void:
	get_tree().get_first_node_in_group("main").restart()
