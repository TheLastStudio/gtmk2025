extends CharacterBody2D
class_name Station

@onready var path = $Path
@onready var car = preload("res://entities/car/car.tscn")

@export var min_x = 1120
@export var max_x = 1700

var current_car

var speed = 200

func _ready() -> void:
	new_car()

func new_car():
	var c = car.instantiate()
	c.global_position = global_position
	get_tree().get_first_node_in_group("game").add_child.call_deferred(c)

func launched():
	await get_tree().create_timer(randf_range(0.5, 2.5)).timeout
	new_car()


func _physics_process(_delta: float) -> void:
	process_input()
	move_and_slide()
	position.x = min(max(position.x, min_x), max_x)
	

func process_input():
	var input_direction = Input.get_action_strength("station_right") - Input.get_action_strength("station_left")
	velocity = Vector2(input_direction * speed, 0)
