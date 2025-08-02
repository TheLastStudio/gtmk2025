extends Node

const MAIN_MENU = preload("res://ui/main_menu/main_menu.tscn")
const GAME = preload("res://game.tscn")
const LOOSE_SCREEN = preload("res://ui/loose_screen/loose_screen.tscn")
const TUTORIAL = preload("res://entities/tutorial/tutorial.tscn")
#const CURSOR_V_4 = preload("res://CursorV4.png")
#const CURSOR_V_5 = preload("res://CursorV5.png")

@onready var scene : Node = $MainMenu
@onready var transitions: CanvasLayer = $Transitions
@onready var space: TextureRect = $BG/TextureRect
@onready var button_sound: Node = $ButtonSound

var player_name = "X"

var paralux_speed = Vector2.ZERO

var last_frame_mouse_state = false

func _ready() -> void:
	player_name = "Employee"+str(randi_range(100,999))
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	button_sound.reconnect()
	
	SilentWolf.configure({
		"api_key": "5qL6XJFDvu8YEpOMsdl7H1clwJ3utC5c9WizBMmP",
		"game_id": "SpaceParkingGMTK2025",
		"log_level": 1
	})
	
	scene.setup_leaderboard()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("forceplay"):
		change_scene(GAME)
	#if space.visible:
	#	space.position += paralux_speed*_delta
	#	paralux_speed *= 0.95
	
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) != last_frame_mouse_state:
	#	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
	#		DisplayServer.cursor_set_custom_image(CURSOR_V_5, DisplayServer.CURSOR_ARROW, Vector2(23,7))
	#	else:
	#		DisplayServer.cursor_set_custom_image(CURSOR_V_4, DisplayServer.CURSOR_ARROW, Vector2(23,7))
	#last_frame_mouse_state = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_x = event.position.x
		var mouse_y = event.position.y
		var relative_x = (mouse_x - 960) / 960
		var relative_y = (mouse_y - 540) / 540
		paralux_speed -= Vector2(relative_x, relative_y)*15

func change_scene(scene_file: Resource):
	transitions.transition()
	await transitions.transit
	if scene:
		scene.queue_free()
		await scene.tree_exited
	
	scene = scene_file.instantiate()
	add_child(scene)
	button_sound.reconnect()
		

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

func win():
	to_menu()

func loose():
	var lifetime = scene.lifetime
	var seconds_in_loop = scene.seconds_in_loop
	await change_scene(LOOSE_SCREEN)
	scene.get_children()[0].set_data(lifetime, seconds_in_loop)


func _on_dialogic_signal(argument: String):
	match argument:
		"intro_name":
			if str(Dialogic.VAR.name) == "":
				Dialogic.VAR.set_variable("name", player_name)
				Dialogic.VAR.set_variable("name_success", true)
			elif str(Dialogic.VAR.name).length() > 15:
				Dialogic.VAR.set_variable("name_success", false)
			elif Words.contains_forbidden_words(str(Dialogic.VAR.name)):
				Dialogic.VAR.set_variable("name_success", false)
			else:
				Dialogic.VAR.set_variable("name_success", true)
		"intro_ended":
			if Dialogic.VAR.tutorial:
				await change_scene(TUTORIAL)
			else:
				await change_scene(GAME)
			player_name = Dialogic.VAR.name
		"richkid_yes":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.richkid(true)
		"richkid_no":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.richkid(false)
		"family_ended":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.new_car_family()
		"virus1_ended":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.new_car_virus()
		"virus2_ended":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.virus_win_rejected = true
			scene.station.new_car_virus()
		"corp1_ended":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.new_car_corp()
		"corp0_ended":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.new_car_corp()
		"corp2_ended":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.corp_win_rejected = true
		"unknown1_yes":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.new_car_unknown()
		"unknown1_no":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.new_car()
		"unknown2_ended":
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			scene.station.unknown_timer_run = true
		"unknown3_ended":
			scene.station.unknown_timer = 60
			scene.station.unknown_win_rejected3 = true
			scene.process_mode = Node.PROCESS_MODE_INHERIT
		"unknown3_ended":
			scene.station.unknown_timer = 60
			scene.station.unknown_win_rejected4 = true
			scene.station.unknown_timer_run = false
			scene.process_mode = Node.PROCESS_MODE_INHERIT
		"finale":
			print("GG?")
			scene.process_mode = Node.PROCESS_MODE_INHERIT
			win()
