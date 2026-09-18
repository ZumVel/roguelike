extends Node
class_name DashComponent

## Сигналы
signal dash_started()
signal dash_ended()
signal dash_cooldown_changed(cooldown: float, max_cooldown: float)

## Настройки рывка
@export var dash_speed: float = 800.0           # Скорость рывка (пикселей/сек)
@export var dash_duration: float = 0.15         # Длительность рывка (секунды)
@export var dash_cooldown: float = 2.0          # Перезарядка между рывками (секунды)
@export var dash_direction_mode: int = 0        # 0 = по направлению движения, 1 = по направлению прицеливания

var body: CharacterBody2D
var _is_dashing: bool = false
var _dash_timer: Timer
var _cooldown_timer: Timer
var _can_dash: bool = true
var _dash_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	body = get_parent() as CharacterBody2D
	if not body:
		push_error("DashComponent должен быть дочерним узлом CharacterBody2D")
		return
	
	# Создаем таймер длительности рывка
	_dash_timer = Timer.new()
	_dash_timer.one_shot = true
	_dash_timer.timeout.connect(_on_dash_timer_timeout)
	add_child(_dash_timer)
	
	# Создаем таймер перезарядки
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	add_child(_cooldown_timer)

## Запросить рывок в указанном направлении
func request_dash(direction: Vector2) -> void:
	if not _can_dash or _is_dashing:
		return
	
	if direction == Vector2.ZERO:
		return
	
	_start_dash(direction.normalized())

## Начать рывок
func _start_dash(direction: Vector2) -> void:
	_is_dashing = true
	_can_dash = false
	_dash_direction = direction
	
	dash_started.emit()
	
	# Запускаем таймер длительности рывка
	_dash_timer.start(dash_duration)

## Выполнить физику рывка (вызывать из _physics_process родителя)
func process_dash(delta: float) -> void:
	if not _is_dashing:
		return
	
	# Применяем скорость рывка
	body.velocity = _dash_direction * dash_speed
	body.move_and_slide()

## Обработка завершения рывка
func _on_dash_timer_timeout() -> void:
	_is_dashing = false
	dash_ended.emit()
	
	# Запускаем таймер перезарядки
	_cooldown_timer.start(dash_cooldown)

## Обработка завершения перезарядки
func _on_cooldown_timer_timeout() -> void:
	_can_dash = true

## Проверить, можно ли сделать рывок
func can_dash() -> bool:
	return _can_dash and not _is_dashing

## Получить текущее состояние рывка
func is_dashing() -> bool:
	return _is_dashing

## Получить оставшееся время перезарядки
func get_cooldown_remaining() -> float:
	if _can_dash:
		return 0.0
	return _cooldown_timer.time_left
