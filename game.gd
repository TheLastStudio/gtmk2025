extends Node2D
class_name Game

@onready var planet: Planet = $Planet
@onready var station: Station = $Station
@onready var ui: Control = $UI/UI
@onready var score_label: Label = $UI/UI/Score
@onready var loop_progress: TextureProgressBar = $UI/UI/LoopProgress
@onready var camera: Camera2D = $Planet/Camera2D
@onready var pause_menu: Control = $PauseMenu/PauseMenu

@export var score := 150
@export var per_loop_payment := 75
@export var seconds_in_loop := 60

var score_label_current_value: int = score
var loop_timer: float = seconds_in_loop

var lifetime := 0.0

var screen_space = {}

var on_exit_timer = false

var rich_kid_satisfied = false

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("screen_space"):
		match node.name:
			"Success":
				screen_space["success"] = node
			"Error":
				screen_space["error"] = node
	
	var tc = Car.new()
	$UI/UI/Rules.text = "Launch payment: {0}¥\nTip: from {1}¥ to {2}¥\nFine: from {3}¥ to {4}¥\nLoan payment: {5}¥ each {6}s".format(
		[tc.launch_reward*100, tc.min_tip*100, tc.max_tip*100, tc.min_fine*100, tc.max_fine*100, per_loop_payment*100, seconds_in_loop]
	)

func _process(delta: float) -> void:
	get_parent().space.position.x = -240 - station.position.x/20
	
	score_label_progress()
	
	loop_timer -= delta
	loop_progress.value = loop_timer / seconds_in_loop
	if loop_timer <= 0:
		loop_timer = seconds_in_loop
		loop_events_trigger()
	
	if score_label_current_value < 0 and not on_exit_timer:
		on_exit_timer = true
		get_tree().get_first_node_in_group("main").loose()
	
	lifetime += delta
	$UI/UI/Lifetime.text = "Loops survived: " + str(snapped(lifetime/seconds_in_loop, 0.1))


func score_label_progress():
	score_label_current_value += sign(score-score_label_current_value)
	score_label.text = str(score_label_current_value*100)+"¥"

func loop_events_trigger():
	change_score(-per_loop_payment)

func change_score(value: int):
	score += value
	
	if value > 0:
		play_cash_added()
	elif value < 0:
		play_cash_subtracted()
	
	var number = Label.new()
	number.position = score_label.position
	number.text = str(value*100)+"¥"
	if value > 0:
		number.text = "+" + number.text
		screen_space["success"].play()
	else:
		screen_space["error"].play()
		
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	number.label_settings.font_color = Color.GREEN if value > 0 else Color.RED
	number.label_settings.font_size = 48
	ui.add_child.call_deferred(number)
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y + 96, 1.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(
		number, "scale", Vector2.ZERO, .75
	).set_delay(.75).set_ease(Tween.EASE_IN)
	
	await tween.finished
	number.queue_free()


func play_cash_subtracted():
	$cash_subtracted_player.play()
	print('[Cash Subtracted SFX]')
	# (поки не готовий ефект)

func play_cash_added():
	$cash_added_player.play()
	print('[Cash Added SFX]')
	# (поки не готовий ефект)

func play_car_bump():
	$car_bump_player.play()

func play_car_death():
	$car_death_player.play()


func _on_rich_kid_satisfied() -> void:
	change_score(randi_range(35,47))
	rich_kid_satisfied = true
