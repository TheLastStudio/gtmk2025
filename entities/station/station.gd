extends CharacterBody2D
class_name Station

@onready var path = $Path
@onready var car = preload("res://entities/car/car.tscn")

var min_x = 1120
var max_x = 1700

var current_car

var speed = 0
var max_speed = 400
var accel = 600
var friction = 500

var game

var event_timer
var event_time_min = 35
var event_time_max = 55 #15 events min in 14 loops

var richkid_dead = false

var infected := 0
var virus_win_rejected := false

var corp_destroyed := 0
var unknown_task := false
var unknown_task_done := false
var unknown_task_timer := 21.0
var unknown_task_target

var unknown_timer_run := false
var unknown_timer := 60.0
var unknown_win_rejected3 := false
var unknown_win_rejected4 := false

enum {
	RICH_KID,
	FAMILY,
	VIRUS1,
	VIRUS0,
	CORP1,
	CORP0,
	UNKNOWN1,
	NONE
}

var unknown_line = [CORP1, UNKNOWN1, CORP0]
var virus_line = [VIRUS1, VIRUS0, VIRUS0]
var other_events = [RICH_KID, FAMILY, RICH_KID, FAMILY, RICH_KID, FAMILY, RICH_KID, FAMILY, NONE]

var event_pool = []

@export var tutorial = false

var frame = 2 :
	set(value):
		frame = value
		match value:
			-1: $StationSketchV2.frame = 1
			1: $StationSketchV2.frame = 0
			0: $StationSketchV2.frame = 2

func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")
	
	randomize()
	event_timer = randf_range(event_time_min, event_time_max)
	
	for n in range(6):
		if len(unknown_line) == 0:
			event_pool.append(virus_line.pop_front())
		elif len(virus_line) == 0:
			event_pool.append(unknown_line.pop_front())
		else:
			if randi_range(0, 1) == 1:
				event_pool.append(unknown_line.pop_front())
			else: event_pool.append(virus_line.pop_front())
		event_pool.append(other_events.pick_random())
	print(event_pool)
	
	if tutorial: return
	new_car()

func _process(delta: float) -> void:
	if tutorial: return
	event_timer -= delta
	if unknown_timer_run: unknown_timer -= delta
	if unknown_task:
		unknown_task_timer -= delta
	if unknown_task_timer < 0:
		unknown_task = false
		unknown_task_target.is_target = false
		unknown_task_timer = 21
	
	if corp_destroyed >= 2 and unknown_task_done \
					and not unknown_win_rejected3 \
					and not unknown_win_rejected4 \
					and not game.on_exit_timer \
					and not unknown_timer_run:
		Dialogic.start("unknown2")
		game.process_mode = Node.PROCESS_MODE_DISABLED
	
	if unknown_timer <= 0 and not game.on_exit_timer:
		if unknown_win_rejected3:
			Dialogic.VAR.set_variable("score", game.score)
			Dialogic.start("unknown4")
			game.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			Dialogic.VAR.set_variable("score", game.score)
			Dialogic.start("unknown3")
			game.process_mode = Node.PROCESS_MODE_DISABLED

func new_car():
	var c = car.instantiate()
	c.global_position = position
	c.tutorial = tutorial
	game.add_child.call_deferred(c)
	#await c.ready
	#$"../KeyPointSpecial".set_car(c)

func new_car_richkid(handler: Node):
	var c = car.instantiate()
	c.global_position = position
	c.special = c.RICH_KID
	game.add_child.call_deferred(c)
	await c.ready
	handler.set_car(c)

func new_car_family():
	var c = car.instantiate()
	c.global_position = position
	c.special = c.FAMILY
	game.add_child.call_deferred(c)
	await c.ready

func new_car_virus():
	var c = car.instantiate()
	c.global_position = position
	c.special = c.VIRUS
	game.add_child.call_deferred(c)
	await c.ready

func new_car_corp():
	var c = car.instantiate()
	c.global_position = position
	c.special = c.CORP
	game.add_child.call_deferred(c)
	await c.ready

func new_car_unknown():
	var carlist = []
	for cc in game.get_children():
		if cc is Car and not cc.leave_ready:
			carlist.append(cc)
	
	unknown_task_target = carlist.pick_random()
	unknown_task_target.is_target = true
	unknown_task_target.max_fine = 5
	unknown_task_target.min_fine = 0
	unknown_task_target.time_on_orbit += 21
	unknown_task_target.time_until_lost += 21
	
	var c = car.instantiate()
	c.global_position = position
	c.special = c.UNKNOWN
	game.add_child.call_deferred(c)
	unknown_task = true
	await c.ready

func launched():
	if game.on_exit_timer: return
	await get_tree().create_timer(randf_range(0.5, 2.5)).timeout
	
	if event_timer <= 0:
		event_timer = randf_range(event_time_min, event_time_max)
		
		if len(event_pool) == 0:
			event_pool = [RICH_KID, CORP0, FAMILY, VIRUS0, NONE, NONE]+[RICH_KID, CORP0, FAMILY, VIRUS0, NONE, NONE]
			event_pool.shuffle()
		
		var event = event_pool.pop_front()
		match event:
			RICH_KID:
				if not richkid_dead:
					Dialogic.start("richkid")
					game.process_mode = Node.PROCESS_MODE_DISABLED
			FAMILY:
				Dialogic.start("family")
				game.process_mode = Node.PROCESS_MODE_DISABLED
			VIRUS1:
				Dialogic.start("virus1")
				game.process_mode = Node.PROCESS_MODE_DISABLED
			VIRUS0:
				new_car_virus()
			CORP1:
				Dialogic.start("corp1")
				game.process_mode = Node.PROCESS_MODE_DISABLED
			CORP0:
				Dialogic.start("corp0")
				game.process_mode = Node.PROCESS_MODE_DISABLED
			UNKNOWN1:
				var carlist = []
				for cc in game.get_children():
					if cc is Car and not cc.leave_ready:
						carlist.append(cc)
				if len(carlist) > 0:
					Dialogic.start("unknown1")
					game.process_mode = Node.PROCESS_MODE_DISABLED
				else:
					event_timer = 0
					event_pool.push_front(UNKNOWN1)
					new_car()
	else:
		new_car()

func richkid(result):
	if result:
		new_car_richkid(get_tree().get_first_node_in_group("specials"))
	else: new_car()


func _physics_process(delta: float) -> void:
	if tutorial:
		if game.state in [game.DIALOG1,	game.DIALOG2,game.FINISH,game.LOOSE]:
			return
	var input_direction = Input.get_action_strength("station_right") - Input.get_action_strength("station_left")
	speed += input_direction * accel * delta
	if sign(speed) != sign(input_direction):
		speed += input_direction * accel * delta * 2  # additonal turning
	if input_direction == 0:
		speed -= friction * sign(speed) * delta
	speed = max(min(speed, max_speed), -max_speed)
	
	if abs(speed) < 12 and input_direction == 0:
		speed = 0
	
	velocity = Vector2(speed, 0)
	move_and_slide()
	if position.x >= max_x or position.x <= min_x:
		speed = 0
	position.x = min(max(position.x, min_x), max_x)
	
	if infected >= 4 and not virus_win_rejected:
		var scs = true
		var counter = 0
		for c in game.get_children():
			if c is Car and c.state == c.ORBITING:
				if c.special != c.VIRUS:
					scs = false
				else:
					counter += 1
		if scs and counter >= 2:
			Dialogic.start("virus2")
			game.process_mode = Node.PROCESS_MODE_DISABLED
