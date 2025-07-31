extends ColorRect

@export var vignette_duration := 0.6
@onready var mat := material as ShaderMaterial

func _ready():
	mat.set_shader_parameter("vignette_intensity", 0.0)

func play():
	show()
	mat.set_shader_parameter("vignette_intensity", .2)
	var tween = get_tree().create_tween()
	tween.tween_property(
		mat, "shader_parameter/vignette_intensity", 0.0, vignette_duration
	)
	await tween.finished
	hide()
