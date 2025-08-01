extends Control

@onready var cursor: Control = $Cursor
@onready var cursor_on: TextureRect = $Cursor/CursorOn
@onready var cursor_off: TextureRect = $Cursor/CursorOff


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(_delta: float) -> void:
	cursor.position = get_global_mouse_position()
	cursor_off.visible = !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	cursor_on.visible = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
