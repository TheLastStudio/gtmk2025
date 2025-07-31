extends Node

const MAIN_MENU = preload("res://ui/main_menu/main_menu.tscn")
const GAME = preload("res://game.tscn")
const LOOSE_SCREEN = preload("res://ui/loose_screen/loose_screen.tscn")

@onready var scene : Node = $MainMenu
@onready var transitions: CanvasLayer = $Transitions

func change_scene(scene_file: Resource):
	transitions.transition()
	await transitions.transit
	if scene:
		scene.queue_free()
		await scene.tree_exited
	
	scene = scene_file.instantiate()
	add_child(scene)
		

func start_game():
	change_scene(GAME)

func to_menu():
	change_scene(MAIN_MENU)

func restart():
	change_scene(GAME)

func loose():
	var lifetime = scene.lifetime
	var seconds_in_loop = scene.seconds_in_loop
	await change_scene(LOOSE_SCREEN)
	scene.get_children()[0].	set_data(lifetime, seconds_in_loop)
