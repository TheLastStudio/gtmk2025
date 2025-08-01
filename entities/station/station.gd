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


var event_timer

@export var tutorial = false

var frame = 2 :
	set(value):
		frame = value
		match value:
			-1: $StationSketchV2.frame = 1
			1: $StationSketchV2.frame = 0
			0: $StationSketchV2.frame = 2

func _ready() -> void:
	event_timer = randf_range(70, 100)
	if tutorial: return
	new_car()

func _process(delta: float) -> void:
	if tutorial: return
	event_timer -= delta

func new_car():
	var c = car.instantiate()
	c.global_position = position
	c.tutorial = tutorial
	get_tree().get_first_node_in_group("game").add_child.call_deferred(c)
	#await c.ready
	#$"../KeyPointSpecial".set_car(c)

func new_car_richkid(handler: Node):
	var c = car.instantiate()
	c.global_position = position
	c.special = c.RICH_KID
	get_tree().get_first_node_in_group("game").add_child.call_deferred(c)
	await c.ready
	handler.set_car(c)

func launched():
	await get_tree().create_timer(randf_range(0.5, 2.5)).timeout
	if event_timer <= 0:
		Dialogic.start("richkid")
		get_tree().get_first_node_in_group("game").process_mode = Node.PROCESS_MODE_DISABLED
	else:
		new_car()

func richkid(result):
	event_timer = randf_range(70, 100)
	if result:
		new_car_richkid(get_tree().get_first_node_in_group("specials"))
	else:
		new_car()


func _physics_process(delta: float) -> void:
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
	
