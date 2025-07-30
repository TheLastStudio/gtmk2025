extends CharacterBody2D

@onready var path = $Path
@onready var car = preload("res://entities/car/car.tscn")

func _ready() -> void:
	add_new()

func add_new():
	var c = car.instantiate()
	c.global_position = global_position
	get_tree().get_first_node_in_group("game").add_child.call_deferred(c)
