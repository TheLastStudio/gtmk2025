extends Node

const MAIN_MENU = preload("res://ui/main_menu/main_menu.tscn")
const GAME = preload("res://game.tscn")
const LOOSE_SCREEN = preload("res://ui/loose_screen/loose_screen.tscn")

@onready var scene : Node = $MainMenu
@onready var transitions: CanvasLayer = $Transitions

var player_name = "X"

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	SilentWolf.configure({
		"api_key": "5qL6XJFDvu8YEpOMsdl7H1clwJ3utC5c9WizBMmP",
		"game_id": "SpaceParkingGMTK2025",
		"log_level": 2
	})
	
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	print("Scores: " + str(sw_result.scores))
	scene.setup_leaderboard()
	

func change_scene(scene_file: Resource):
	transitions.transition()
	await transitions.transit
	if scene:
		scene.queue_free()
		await scene.tree_exited
	
	scene = scene_file.instantiate()
	add_child(scene)
		

func start_game():
	transitions.transition()
	await transitions.transit
	scene.hide()
	Dialogic.start("intro")
	#change_scene(GAME)

func to_menu():
	await change_scene(MAIN_MENU)
	scene.setup_leaderboard()

func restart():
	change_scene(GAME)

func loose():
	var lifetime = scene.lifetime
	var seconds_in_loop = scene.seconds_in_loop
	await change_scene(LOOSE_SCREEN)
	scene.get_children()[0].	set_data(lifetime, seconds_in_loop)


func _on_dialogic_signal(argument: String):
	match argument:
		"intro_ended":
			await change_scene(GAME)
			player_name = Dialogic.VAR.name
	
