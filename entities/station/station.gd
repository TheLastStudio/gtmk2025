extends CharacterBody2D
class_name Station

@onready var path = $Path
@onready var car = preload("res://entities/car/car.tscn")

@export var min_x = 1120
@export var max_x = 1700

var current_car

var speed = 0
@export var max_speed = 400
@export var accel = 600
@export var friction = 500


func _ready() -> void:
	new_car()

func new_car():
	var c = car.instantiate()
	c.global_position = position
	get_tree().get_first_node_in_group("game").add_child.call_deferred(c)

func launched():
	await get_tree().create_timer(randf_range(0.5, 2.5)).timeout
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
	
