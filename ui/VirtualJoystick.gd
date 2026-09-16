extends Control
class_name VirtualJoystick

signal vector_changed(vector: Vector2)

@export var deadzone: float = 0.1
@export var max_radius: float = 50.0
@export var knob_size: float = 30.0

var _base_pos: Vector2 = Vector2.ZERO
var _knob_pos: Vector2 = Vector2.ZERO
var _is_pressed: bool = false
var _touch_id: int = -1
var _output_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	_base_pos = size / 2.0
	_knob_pos = _base_pos

func _draw() -> void:
	draw_circle(_base_pos, max_radius, Color(0.2, 0.2, 0.2, 0.3))
	draw_circle(_knob_pos, knob_size, Color(0.4, 0.6, 1.0, 0.8))

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)
	elif event is InputEventMouseButton:
		_handle_mouse(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	var touch_pos = event.position
	var dist = touch_pos.distance_to(global_position + _base_pos)
	
	if event.pressed and dist < max_radius * 1.5:
		if not _is_pressed:
			_is_pressed = true
			_touch_id = event.index
			_update_knob(touch_pos)
	elif not event.pressed and event.index == _touch_id:
		_is_pressed = false
		_touch_id = -1
		_reset_knob()

func _handle_drag(event: InputEventScreenDrag) -> void:
	if _is_pressed and event.index == _touch_id:
		_update_knob(event.position)

func _handle_mouse(event: InputEventMouseButton) -> void:
	var mouse_pos = event.position
	var dist = mouse_pos.distance_to(global_position + _base_pos)
	
	if event.pressed and dist < max_radius * 1.5:
		if not _is_pressed:
			_is_pressed = true
			_update_knob(mouse_pos)
	elif not event.pressed and _is_pressed:
		_is_pressed = false
		_reset_knob()

func _update_knob(touch_pos: Vector2) -> void:
	var local_pos = touch_pos - global_position
	var dir = (local_pos - _base_pos).normalized()
	var dist = min(local_pos.distance_to(_base_pos), max_radius)
	
	_knob_pos = _base_pos + dir * dist
	_output_vector = (dir * (dist / max_radius)).clamped(1.0)
	
	if _output_vector.length() < deadzone:
		_output_vector = Vector2.ZERO
	
	queue_redraw()
	vector_changed.emit(_output_vector)

func _reset_knob() -> void:
	_knob_pos = _base_pos
	_output_vector = Vector2.ZERO
	queue_redraw()
	vector_changed.emit(Vector2.ZERO)

func get_output_vector() -> Vector2:
	return _output_vector
