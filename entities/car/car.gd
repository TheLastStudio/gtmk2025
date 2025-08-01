extends RigidBody2D
class_name  Car

enum {SETTING, ORBITING}

var state = SETTING
var game : Node

var base_max_launch_speed = 600
var max_launch_speed = 600
var launch_dir

var max_time_on_orbit := 50.0
var min_time_on_orbit := 10.0
var time_on_orbit: float
var time_until_lost: float
var leave_ready := false

var launch_reward = 3
var min_tip = 0
var max_tip = 20
var min_fine = 20
var max_fine = 45

var time = 0

var engine_type = -1

var last_frame_pos
var pos_to_center

var count = -1

var tutorial = false

@onready var key_point_area: Area2D = $KeyPointArea

var pickup_indicator = preload("res://entities/car/pickup__indicator.tscn")

enum  {
	NONE,
	RICH_KID,
	RICH_KID_REJECTED
}

var special = NONE


func _ready() -> void:
	last_frame_pos = position
	engine_type = randi_range(0, 1)*2 - 1
	game = get_tree().get_first_node_in_group("game")
	#modulate = Color(randf(), randf(), randf())
	time_on_orbit = randf_range(min_time_on_orbit, max_time_on_orbit)
	if tutorial: time_on_orbit = 12.5
	time_until_lost = time_on_orbit*2.5
	if special == NONE:
		randomize_sprite()
	elif special == RICH_KID or special == RICH_KID_REJECTED:
		randomize_sprite() #SPECIAL SPRITE!!!

func randomize_sprite():
	$Sprite/Bottom.frame_coords.y = randi_range(0, 2)
	$Sprite/Top.frame_coords.y = randi_range(0, 2)
	$Sprite/Bottom.frame_coords.x = randi_range(4, 7)
	$Sprite/Top.frame_coords.x = randi_range(0, 3)

func _process(delta: float) -> void:
	time += delta
	if not leave_ready and state == ORBITING:
		time_on_orbit -= delta
		if time_on_orbit <= 0:
			leave_ready = true
			count = time
	elif leave_ready:
		if time > count:
			count += 1
			var pickup = pickup_indicator.instantiate()
			add_child(pickup)
		
		#modulate = Color(randf(), randf(), randf())
	
	if state == ORBITING:
		time_until_lost -= delta
		if time_until_lost <= 0:
			game.change_score(randi_range(-max_fine, -min_fine))
			game.camera.apply_shake()
			queue_free()
	
	
 
func _physics_process(delta: float) -> void:
	#$Label.text = str(engine_type)
	if rotation_direction(position, last_frame_pos, game.planet.position, delta) != engine_type:
		linear_damp = 0.3
	else:
		linear_damp = 0.0
	
	var distance = (game.station.position - game.planet.position).length()
	max_launch_speed = base_max_launch_speed*sqrt(1/distance)*12.3 - distance**2/5500 #*11.7 /9900
	launch_dir = get_global_mouse_position() - game.station.global_position
	
	if state == SETTING:
		game.station.frame = engine_type
		position = game.station.position
		if dragging:
			$DragLine.points[1] = (launch_dir.normalized())*min(max_launch_speed*2/3, launch_dir.length())
			if (global_position-get_global_mouse_position()).length() >= 60:
				generate_path(-(launch_dir.normalized())*3*min(max_launch_speed*2/3, launch_dir.length()))
			else:
				game.station.path.clear_points()
			
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
			else:
				max_tip = 0 if max_tip == 2 else 2
	last_frame_pos = position

var dragging := false
func _input(event: InputEvent) -> void:
	if state == SETTING:
		if event is InputEventMouseButton:
			if event.button_index == 1:
				if event.pressed:
					dragging = true
				elif dragging == true:
					dragging = false
					if (global_position-get_global_mouse_position()).length() < 60:
						$DragLine.points[1] = Vector2.ZERO
						return
					state = ORBITING
					linear_velocity = -(launch_dir.normalized())*3*min(max_launch_speed*2/3, launch_dir.length())
					$DragLine.hide()
					game.station.launched()
					collision_layer = 0b00000001
					collision_mask = 0b00000001
					$Trail.show()
					game.station.path.clear_points()
					game.change_score(launch_reward)
					game.station.frame = 0
					#linear_velocity = Vector2.RIGHT*(sqrt(.2e10/mass/(global_position - $"../Center".global_position).length()))*1.25

func generate_path(velocity):
	var GMm = .2e10
	var delta = 1.0/60
	var pos = Vector2.ZERO
	var center_position = game.planet.global_position - global_position
	var accel = Vector2.ZERO
	game.station.path.clear_points()
	game.station.path.modulate = Color.WHITE
	var wrong = velocity.y * engine_type > 0
	if wrong:
		game.station.path.modulate = Color.DARK_ORANGE
		
	
	for x in 128:
		game.station.path.add_point(pos)
		accel = ((center_position - pos).normalized() * GMm/((center_position - pos).length()**2))/mass
		velocity += accel*delta
		if wrong: velocity *= 0.995
		pos += velocity*delta
		if (center_position - pos).length() <= 98:
			game.station.path.modulate = Color.RED if not wrong else Color.DARK_ORANGE
			break
	for x in 1024:
		accel = ((center_position - pos).normalized() * GMm/((center_position - pos).length()**2))/mass
		velocity += accel*delta
		if wrong: velocity *= 0.995
		pos += velocity*delta
		if (center_position - pos).length() <= 98:
			game.station.path.modulate = Color.RED if not wrong else Color.DARK_ORANGE
			break

func rotation_direction(p, last_p, center, dt):
	var r = p - center
	var v = (last_p - p)/dt
	
	var a_vel = r[0]*v[1] - r[1]*v[0]
	
	if a_vel > 0:
		return 1
	elif a_vel < 0:
		return -1
	return 0

func _on_capture_area_body_entered(_body: Node2D) -> void:
	if leave_ready:
		if special == RICH_KID:
			if game.rich_kid_satisfied:
				game.change_score(randi_range(min_tip*1.2, max_tip))
			else:
				game.change_score(0)
		if tutorial:
			get_tree().get_first_node_in_group("game").catched()
		queue_free()
