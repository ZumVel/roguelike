extends Node2D
class_name InputComponent

@export var up_action:   String = "ui_up"
@export var down_action: String = "ui_down"
@export var left_action: String = "ui_left"
@export var right_action:String = "ui_right"

@export var fire_action: String = "ui_accept"
@export var dash_action: String = "ui_focus"

var _is_mobile: bool = false
var _mobile_move_vector: Vector2 = Vector2.ZERO
var _mobile_aim_vector: Vector2 = Vector2.RIGHT
var _mobile_dash_pressed: bool = false

func _ready() -> void:
	_is_mobile = OS.get_name() in ["Android", "iOS"]
	
	if _is_mobile:
		_setup_mobile_input()

func _setup_mobile_input() -> void:
	pass

func get_input_vector() -> Vector2:
	if _is_mobile:
		return _mobile_move_vector.normalized()
	
	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength(right_action) - Input.get_action_strength(left_action)
	dir.y = Input.get_action_strength(down_action) - Input.get_action_strength(up_action)
	return dir.normalized()

func _get_mouse_world_position() -> Vector2:
	return get_global_mouse_position()

func get_aim_direction(origin: Vector2) -> Vector2:
	if _is_mobile:
		return _mobile_aim_vector.normalized()
	
	var mouse_pos := _get_mouse_world_position()
	var dir := mouse_pos - origin
	return dir.normalized()

func is_firing() -> bool:
	if _is_mobile:
		return _mobile_aim_vector.length() > 0.1
	return Input.is_action_pressed(fire_action)

func is_dashing() -> bool:
	if _is_mobile:
		if _mobile_dash_pressed:
			_mobile_dash_pressed = false
			return true
		return false
	return Input.is_action_just_pressed(dash_action)

func set_mobile_move_vector(vector: Vector2) -> void:
	_mobile_move_vector = vector

func set_mobile_aim_vector(vector: Vector2) -> void:
	_mobile_aim_vector = vector

func trigger_mobile_dash() -> void:
	_mobile_dash_pressed = true

func is_mobile() -> bool:
	return _is_mobile
