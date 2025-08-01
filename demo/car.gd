extends RigidBody2D

enum {SETTING, ORBITING}

var state = SETTING

func _ready() -> void:
	randomize()
	modulate = Color(randf(), randf(), randf())

func _physics_process(_delta: float) -> void:
	if state == SETTING:
		if dragging:
			$Line2D.points[1] = -drag_start + get_global_mouse_position()
			generate_path((-get_global_mouse_position() + drag_start)*2)
	elif state == ORBITING:
		var mouse_pos = get_global_mouse_position()
		mouse_pos = $"../Center".global_position
		var vector = mouse_pos - global_position
		apply_central_force(.2e10*vector.normalized()/(vector.length()**2))
		for b in get_colliding_bodies():
			if b.name == "Center":
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
					linear_velocity = (-get_global_mouse_position() + drag_start)*2
					$Line2D.hide()
					$"..".add_new()
					collision_layer = 0b00000001
					collision_mask = 0b00000001
					#linear_velocity = Vector2.RIGHT*(sqrt(.2e10/mass/(global_position - $"../Center".global_position).length()))*1.25

func generate_path(velocity):
	var GMm = .2e10
	var delta = 1.0/60
	var pos = Vector2.ZERO
	var center_position = $"../Center".global_position - global_position
	var accel = Vector2.ZERO
	$"../Trajectory".clear_points()
	$"../Trajectory".modulate = Color.WHITE
	
	for x in 7000:
		$"../Trajectory".add_point(pos)
		accel = ((center_position - pos).normalized() * GMm/((center_position - pos).length()**2))/mass
		velocity += accel*delta
		pos += velocity*delta
		if (center_position - pos).length() <= 150:
			$"../Trajectory".modulate = Color.RED
			break
			
	
