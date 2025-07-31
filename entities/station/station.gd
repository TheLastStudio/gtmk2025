extends CharacterBody2D

@onready var path = $Path
@onready var car = preload("res://entities/car/car.tscn")

var speed = 200

func _ready() -> void:
	add_new()

func add_new():
	var c = car.instantiate()
	c.global_position = global_position
	get_tree().get_first_node_in_group("game").add_child.call_deferred(c)

func _physics_process(delta: float) -> void:
	process_input()
	
	move_and_slide()

func process_input():
	var input_direction = Input.get_action_strength("station_right") - Input.get_action_strength("station_left")
	velocity = Vector2(input_direction * speed, 0)
