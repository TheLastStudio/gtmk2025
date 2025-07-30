extends Node2D

@onready var car = preload("res://car.tscn")

func add_new():
	var c = car.instantiate()
	c.position = Vector2(876, 905)
	add_child(c)
