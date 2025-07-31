extends Node

@export var keypoints: Array[Area2D]
@export var target_car: Car

var _keypoints: Array[Area2D]

signal satisfied

func set_car(car: Car):
	target_car = car
	_keypoints = keypoints.duplicate()
	target_car.key_point_area.area_exited.connect(_on_keypoint)

func _on_keypoint(area: Area2D):
	if target_car.state != target_car.ORBITING: return
	if area in _keypoints:
		_keypoints.erase(area)
	if _keypoints.is_empty():
		satisfied.emit()
		target_car.key_point_area.area_exited.disconnect(_on_keypoint)
