extends RigidBody2D

enum {SETTING, ORBITING}

var state = SETTING
var game : Game

var base_max_launch_speed = 600
var max_launch_speed = 600
var launch_dir


func _ready() -> void:
	game = get_tree().get_first_node_in_group("game")
	randomize()
	modulate = Color(randf(), randf(), randf())

func _physics_process(_delta: float) -> void:
	max_launch_speed = base_max_launch_speed*sqrt(1/(get_parent().station.position - get_parent().planet.position).length())*11.7
	launch_dir = get_global_mouse_position() - get_parent().station.position
	if state == SETTING:
		position = get_parent().station.position
		if dragging:
			$Line2D.points[1] = (launch_dir.normalized())*min(max_launch_speed, launch_dir.length())
			generate_path(-(launch_dir.normalized())*2*min(max_launch_speed, launch_dir.length()))
	elif state == ORBITING:
		var mouse_pos = get_global_mouse_position()
		mouse_pos = game.planet.global_position
		var vector = mouse_pos - global_position
		apply_central_force(.2e10*vector.normalized()/(vector.length()**2))
		for b in get_colliding_bodies():
			if b.name == "Planet":
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
					$Line2D.hide()
					game.station.add_new()
					collision_layer = 0b00000001
					collision_mask = 0b00000001
					generate_path(-1)
					#linear_velocity = Vector2.RIGHT*(sqrt(.2e10/mass/(global_position - $"../Center".global_position).length()))*1.25
func generate_path(velocity):
	if velocity is not int:
		var GMm = .2e10
		var delta = 1.0/60
		var pos = Vector2.ZERO
		var center_position = game.planet.global_position - global_position
		var accel = Vector2.ZERO
		game.station.path.clear_points()
		game.station.path.modulate = Color.WHITE
		
		for x in 7000:
			game.station.path.add_point(pos)
			accel = ((center_position - pos).normalized() * GMm/((center_position - pos).length()**2))/mass
			velocity += accel*delta
			pos += velocity*delta
			if (center_position - pos).length() <= 95:
				game.station.path.modulate = Color.RED
				break
	else:
		game.station.path.clear_points()
