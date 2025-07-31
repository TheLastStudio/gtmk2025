extends RigidBody2D
class_name  Car

enum {SETTING, ORBITING}

var state = SETTING
var game : Game

var base_max_launch_speed = 600
var max_launch_speed = 600
var launch_dir

var max_time_on_orbit := 50.0
var min_time_on_orbit := 10.0
var time_on_orbit: float
var leave_ready := false

var launch_reward = 2
var min_tip = 0
var max_tip = 15
var min_fine = 15
var max_fine = 45


func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")
	modulate = Color(randf(), randf(), randf())
	time_on_orbit = randf_range(min_time_on_orbit, max_time_on_orbit)

func _process(delta: float) -> void:
	if not leave_ready and state == ORBITING:
		time_on_orbit -= delta
		if time_on_orbit <= 0:
			leave_ready = true
	elif leave_ready:
		modulate = Color(randf(), randf(), randf())

func _physics_process(_delta: float) -> void:
	var distance = (game.station.position - game.planet.position).length()
	max_launch_speed = base_max_launch_speed*sqrt(1/distance)*11.7 - distance**2/5000
	launch_dir = get_global_mouse_position() - game.station.position
	
	if state == SETTING:
		position = game.station.position
		if dragging:
			$DragLine.points[1] = (launch_dir.normalized())*min(max_launch_speed, launch_dir.length())
			generate_path(-(launch_dir.normalized())*2*min(max_launch_speed, launch_dir.length()))
	
	elif state == ORBITING:
		var mouse_pos = get_global_mouse_position()
		mouse_pos = game.planet.global_position
		var vector = mouse_pos - global_position
		apply_central_force(.2e10*vector.normalized()/(vector.length()**2))
		for b in get_colliding_bodies():
			if b.name == "Planet":
				game.change_score(randi_range(-max_fine, -min_fine))
				game.camera.apply_shake()
				queue_free()

var dragging := false
var drag_start := Vector2.ZERO
func _input(event: InputEvent) -> void:
	if state == SETTING:
		if event is InputEventMouseButton:
			if event.button_index == 1:
				if event.pressed:
					dragging = true
					drag_start = get_global_mouse_position()
				elif dragging == true:
					dragging = false
					state = ORBITING
					linear_velocity = -(launch_dir.normalized())*2*min(max_launch_speed, launch_dir.length())
					$DragLine.hide()
					game.station.launched()
					collision_layer = 0b00000001
					collision_mask = 0b00000001
					game.station.path.clear_points()
					game.change_score(launch_reward)
					#linear_velocity = Vector2.RIGHT*(sqrt(.2e10/mass/(global_position - $"../Center".global_position).length()))*1.25

func generate_path(velocity):
	var GMm = .2e10
	var delta = 1.0/60
	var pos = Vector2.ZERO
	var center_position = game.planet.global_position - global_position
	var accel = Vector2.ZERO
	game.station.path.clear_points()
	game.station.path.modulate = Color.WHITE
	
	for x in 128:
		game.station.path.add_point(pos)
		accel = ((center_position - pos).normalized() * GMm/((center_position - pos).length()**2))/mass
		velocity += accel*delta
		pos += velocity*delta
		if (center_position - pos).length() <= 105:
			game.station.path.modulate = Color.RED
			break
	for x in 1000:
		accel = ((center_position - pos).normalized() * GMm/((center_position - pos).length()**2))/mass
		velocity += accel*delta
		pos += velocity*delta
		if (center_position - pos).length() <= 105:
			game.station.path.modulate = Color.RED
			break


func _on_capture_area_body_entered(_body: Node2D) -> void:
	if leave_ready:
		queue_free()
		game.change_score(randi_range(min_tip, max_tip))
