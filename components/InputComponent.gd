extends Node2D
class_name InputComponent

@export var up_action:   String = "ui_up"
@export var down_action: String = "ui_down"
@export var left_action: String = "ui_left"
@export var right_action:String = "ui_right"

@export var fire_action: String = "ui_accept"

func get_input_vector() -> Vector2:
	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength(right_action) - Input.get_action_strength(left_action)
	dir.y = Input.get_action_strength(down_action) - Input.get_action_strength(up_action)
	return dir.normalized()

func _get_mouse_world_position() -> Vector2:
	return get_global_mouse_position()

func get_aim_direction(origin: Vector2) -> Vector2:
	var mouse_pos := _get_mouse_world_position()
	var dir := mouse_pos - origin
	return dir.normalized()

func is_firing() -> bool:
	return Input.is_action_pressed(fire_action) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
