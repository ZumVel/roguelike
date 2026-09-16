extends Node
class_name DashComponent

@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0
@export var dash_direction: Vector2 = Vector2.RIGHT

var _is_dashing: bool = false
var _can_dash: bool = true
var _dash_timer: Timer = null
var _cooldown_timer: Timer = null

func _ready() -> void:
	_dash_timer = Timer.new()
	_dash_timer.one_shot = true
	_dash_timer.wait_time = dash_duration
	_dash_timer.timeout.connect(_on_dash_finished)
	add_child(_dash_timer)
	
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.wait_time = dash_cooldown
	_cooldown_timer.timeout.connect(_on_cooldown_finished)
	add_child(_cooldown_timer)

func can_dash() -> bool:
	return _can_dash and not _is_dashing

func start_dash(direction: Vector2) -> void:
	if not can_dash():
		return
	
	_is_dashing = true
	_can_dash = false
	_dash_direction = direction.normalized()
	_dash_timer.start()
	_cooldown_timer.start()

func get_dash_velocity() -> Vector2:
	if _is_dashing:
		return _dash_direction * dash_speed
	return Vector2.ZERO

func is_dashing() -> bool:
	return _is_dashing

func _on_dash_finished() -> void:
	_is_dashing = false

func _on_cooldown_finished() -> void:
	_can_dash = true
