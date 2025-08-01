extends CanvasLayer
class_name MainMenu

var scores
var list_index = 0
const ScoreItem = preload("res://ui/main_menu/LeaderboardItem.tscn")

func setup_leaderboard() -> void:
	var sw_result = await SilentWolf.Scores.get_scores(20).sw_get_scores_complete
	$Menu/VBoxContainer/HBoxContainer/LeaderboardContainer/Label.hide()
	scores = sw_result.scores
	for score in scores:
		add_item(score.player_name, str(float(score.score)))


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


func _on_leaderboard_pressed() -> void:
	pass

func add_item(player_name: String, score_value: String) -> void:
	var item = ScoreItem.instantiate()
	list_index += 1
	item.get_node("PlayerName").text = str(list_index) + str(". ") + player_name
	item.get_node("Score").text = score_value
	item.offset_top = list_index * 100
	if $Menu/VBoxContainer/HBoxContainer/LeaderboardContainer.get_child_count() <= 10:
		$Menu/VBoxContainer/HBoxContainer/LeaderboardContainer.add_child(item)
	else:
		$Menu/VBoxContainer/HBoxContainer/LeaderboardContainer2.add_child(item)
