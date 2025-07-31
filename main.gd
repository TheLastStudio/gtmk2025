extends Node

const MAIN_MENU = preload("res://ui/main_menu/main_menu.tscn")
const GAME = preload("res://game.tscn")

@onready var main_menu: MainMenu = $MainMenu
var game: Game
@onready var transitions: CanvasLayer = $Transitions

func start_game():
	transitions.transition()
	await transitions.transit
	
	main_menu.queue_free()
	await main_menu.tree_exited
	game = GAME.instantiate()
	add_child(game)

func to_menu():
	transitions.transition()
	await transitions.transit
		
	game.queue_free()
	await game.tree_exited
	main_menu = MAIN_MENU.instantiate()
	add_child(main_menu)


func restart():
	transitions.transition()
	await transitions.transit
	
	game.queue_free()
	await game.tree_exited
	game = GAME.instantiate()
	add_child(game)
