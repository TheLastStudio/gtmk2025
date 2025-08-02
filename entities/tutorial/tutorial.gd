extends Node2D
class_name Tutorial

@onready var planet: Planet = $Planet
@onready var station: Station = $Station
@onready var ui: Control = $UI/UI
@onready var score_label: Label = %Score
@onready var loop_progress: TextureProgressBar = %LoopProgress
@onready var camera: Camera2D = $Planet/Camera2D


@export var score := 150
@export var per_loop_payment := 75
@export var seconds_in_loop := 60

var score_label_current_value: int = score
var loop_timer: float = seconds_in_loop

var screen_space = {}

enum {
	DIALOG1,
	FIRST_LAUNCHES,
	DIALOG2,
	CATCH,
	FINISH,
	LOOSE
}

var state = DIALOG1

var lifetime := 0.0
var on_exit_timer = false

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("screen_space"):
		match node.name:
			"Success":
				screen_space["success"] = node
			"Error":
				screen_space["error"] = node
	
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.start("tutorial1")
	

func _process(delta: float) -> void:
	score_label_progress()
	if state == FIRST_LAUNCHES:
		loop_timer -= delta
		for c in get_children():
			if c is Car:
				if c.leave_ready:
					for cc in get_children():
						if cc is Car:
							if cc.state == cc.SETTING:
								cc.hide()
								cc.queue_free()
								station.path.clear_points()
							cc.process_mode = Node.PROCESS_MODE_DISABLED
					state = DIALOG2
					Dialogic.start("tutorial2")
					return
	elif state == CATCH:
		loop_timer -= delta
		
	loop_progress.value = loop_timer / seconds_in_loop
	if loop_timer <= 0:
		loop_timer = seconds_in_loop
		loop_events_trigger()
	
	if score_label_current_value < 0 and state != LOOSE and (state == FIRST_LAUNCHES or state == CATCH):
		state = LOOSE
		Dialogic.start("tutorialL")

func score_label_progress():
	score_label_current_value += sign(score-score_label_current_value)
	score_label.text = str(score_label_current_value*100)+"¥"

func loop_events_trigger():
	change_score(-per_loop_payment)

func change_score(value: int):
	score += value
	
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


func catched():
	state = FINISH
	for cc in get_children():
		if cc is Car:
			cc.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	await get_tree().create_timer(.6).timeout
	Dialogic.start("tutorial3")
	


func _on_dialogic_signal(argument: String):
	match argument:
		"tutorial_showui":
			get_tree().create_tween().tween_property($UI/UI, "modulate:a", 1.0, .5)
		"tutorial_showid":
			station.frame = 1
		"tutorial_hideid":
			station.frame = 0
		"tutorial1_showbtn":
			get_tree().create_tween().tween_property($Station/ButtonsV2, "modulate:a", 1.0, .5)
		"tutorial1_ended":
			state = FIRST_LAUNCHES
			station.new_car()
			await get_tree().create_timer(4.5).timeout
			get_tree().create_tween().tween_property($Station/ButtonsV2, "modulate:a", 0.0, .5)
		"tutorial2_ended":
			state = CATCH
			for cc in get_children():
				if cc is Car:
					cc.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
			station.launched()
		"tutorial3_ended":
			get_tree().get_first_node_in_group("main").change_scene(get_tree().get_first_node_in_group("main").GAME)
		"tutorialL_ended":
			get_tree().get_first_node_in_group("main").to_menu()
			

func play_cash_subtracted():
	$cash_subtracted_player.play()

func play_cash_added():
	$cash_added_player.play()

func play_car_bump():
	$car_bump_player.play()

func play_car_death():
	$car_death_player.play()

func play_car_launched():
	$car_launched_player.play()

func play_pick_up_notify():
	$pick_up_notify_player.play()
