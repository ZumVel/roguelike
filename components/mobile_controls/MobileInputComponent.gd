extends Node2D
class_name MobileInputComponent

## Сигналы для передачи данных ввода
signal move_vector_changed(value: Vector2)
signal aim_vector_changed(value: Vector2)
signal dash_requested()
signal fire_started()
signal fire_ended()

## Настройки джойстиков
@export var move_joystick_range: float = 50.0
@export var aim_joystick_range: float = 50.0
@export var joystick_deadzone: float = 0.1

## Внутреннее состояние
var _move_vector: Vector2 = Vector2.ZERO
var _aim_vector: Vector2 = Vector2.ZERO
var _move_touch_id: int = -1
var _aim_touch_id: int = -1
var _move_joystick_origin: Vector2 = Vector2.ZERO
var _aim_joystick_origin: Vector2 = Vector2.ZERO
var _move_joystick_current: Vector2 = Vector2.ZERO
var _aim_joystick_current: Vector2 = Vector2.ZERO
var _fire_button_rect: Rect2 = Rect2(0, 0, 80, 80)
var _dash_button_rect: Rect2 = Rect2(0, 0, 70, 70)

## Позиции кнопок на экране (в пикселях от краев)
@export var move_joystick_position: Vector2 = Vector2(150, -150)  # слева снизу
@export var aim_joystick_position: Vector2 = Vector2(-150, -150)  # справа снизу
@export var fire_button_position: Vector2 = Vector2(-120, -80)    # справа над джойстиком аима
@export var dash_button_position: Vector2 = Vector2(-220, -150)   # левее кнопки огня

# Публичные свойства для чтения UI компонентом (через get методы)
func get_move_joystick_position() -> Vector2:
	return move_joystick_position

func get_aim_joystick_position() -> Vector2:
	return aim_joystick_position

func get_fire_button_position() -> Vector2:
	return fire_button_position

func get_dash_button_position() -> Vector2:
	return dash_button_position

func _ready() -> void:
	# Проверяем, запущено ли на мобильном устройстве
	if not _is_mobile_device():
		set_process_input(false)
		set_physics_process(false)
		return
	
	# Обновляем позиции кнопок при изменении размера окна
	get_viewport().size_changed.connect(_update_button_positions)
	_update_button_positions()

func _is_mobile_device() -> bool:
	# Определяем мобильное устройство по платформе или наличию тач-ввода
	if OS.get_name() in ["Android", "iOS"]:
		return true
	# Также можно проверять наличие тач-ввода
	if Input.has_touchscreen_ui_hint():
		return true
	return false

func _update_button_positions() -> void:
	var viewport_size = get_viewport_rect().size
	
	# Движение: слева снизу
	if move_joystick_position.x > 0:
		_move_joystick_origin = Vector2(move_joystick_position.x, viewport_size.y + move_joystick_position.y)
	else:
		_move_joystick_origin = Vector2(viewport_size.x + move_joystick_position.x, viewport_size.y + move_joystick_position.y)
	
	# Прицеливание: справа снизу
	if aim_joystick_position.x > 0:
		_aim_joystick_origin = Vector2(aim_joystick_position.x, viewport_size.y + aim_joystick_position.y)
	else:
		_aim_joystick_origin = Vector2(viewport_size.x + aim_joystick_position.x, viewport_size.y + aim_joystick_position.y)
	
	# Кнопка огня: справа
	if fire_button_position.x > 0:
		_fire_button_rect = Rect2(
			fire_button_position.x - 40,
			viewport_size.y + fire_button_position.y - 40,
			80, 80
		)
	else:
		_fire_button_rect = Rect2(
			viewport_size.x + fire_button_position.x - 40,
			viewport_size.y + fire_button_position.y - 40,
			80, 80
		)
	
	# Кнопка рывка: левее кнопки огня
	if dash_button_position.x > 0:
		_dash_button_rect = Rect2(
			dash_button_position.x - 35,
			viewport_size.y + dash_button_position.y - 35,
			70, 70
		)
	else:
		_dash_button_rect = Rect2(
			viewport_size.x + dash_button_position.x - 35,
			viewport_size.y + dash_button_position.y - 35,
			70, 70
		)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	var touch_pos = event.position
	var touch_id = event.index
	
	if event.pressed:
		# Проверяем попадание в кнопку огня
		if _fire_button_rect.has_point(touch_pos):
			fire_started.emit()
			return
		
		# Проверяем попадание в кнопку рывка
		if _dash_button_rect.has_point(touch_pos):
			dash_requested.emit()
			return
		
		# Проверяем попадание в зону джойстика движения
		if touch_pos.distance_to(_move_joystick_origin) < move_joystick_range * 1.5:
			_move_touch_id = touch_id
			_move_joystick_current = touch_pos
			_update_move_vector()
			return
		
		# Проверяем попадание в зону джойстика прицеливания
		if touch_pos.distance_to(_aim_joystick_origin) < aim_joystick_range * 1.5:
			_aim_touch_id = touch_id
			_aim_joystick_current = touch_pos
			_update_aim_vector()
			return
	else:
		# Отпустили палец
		if touch_id == _move_touch_id:
			_move_touch_id = -1
			_move_vector = Vector2.ZERO
			move_vector_changed.emit(_move_vector)
		elif touch_id == _aim_touch_id:
			_aim_touch_id = -1
			_aim_vector = Vector2.ZERO
			aim_vector_changed.emit(_aim_vector)
		elif _fire_button_rect.has_point(touch_pos):
			fire_ended.emit()

func _handle_drag(event: InputEventScreenDrag) -> void:
	var touch_pos = event.position
	var touch_id = event.index
	
	if touch_id == _move_touch_id:
		_move_joystick_current = touch_pos
		_update_move_vector()
	elif touch_id == _aim_touch_id:
		_aim_joystick_current = touch_pos
		_update_aim_vector()

func _update_move_vector() -> void:
	var delta = _move_joystick_current - _move_joystick_origin
	var distance = delta.length()
	
	if distance < joystick_deadzone * move_joystick_range:
		_move_vector = Vector2.ZERO
	else:
		var normalized_distance = min(distance / move_joystick_range, 1.0)
		_move_vector = delta.normalized() * normalized_distance
	
	move_vector_changed.emit(_move_vector)

func _update_aim_vector() -> void:
	var delta = _aim_joystick_current - _aim_joystick_origin
	var distance = delta.length()
	
	if distance < joystick_deadzone * aim_joystick_range:
		_aim_vector = Vector2.ZERO
	else:
		var normalized_distance = min(distance / aim_joystick_range, 1.0)
		_aim_vector = delta.normalized() * normalized_distance
	
	aim_vector_changed.emit(_aim_vector)

## Получить вектор движения (нормализованный, от -1 до 1)
func get_move_vector() -> Vector2:
	return _move_vector

## Получить вектор прицеливания (нормализованный, от -1 до 1)
func get_aim_vector() -> Vector2:
	return _aim_vector

## Проверить, активен ли огонь
func is_firing() -> bool:
	# Здесь можно добавить дополнительную логику, если нужно
	return false

## Нарисовать джойстики и кнопки для отладки/визуализации
func _draw() -> void:
	if not _is_mobile_device():
		return
	
	# Рисуем джойстик движения
	_draw_joystick(_move_joystick_origin, _move_joystick_current, move_joystick_range, Color(0, 0.5, 1, 0.5))
	
	# Рисуем джойстик прицеливания
	_draw_joystick(_aim_joystick_origin, _aim_joystick_current, aim_joystick_range, Color(1, 0.5, 0, 0.5))
	
	# Рисуем кнопку огня
	draw_circle(_fire_button_rect.position + Vector2(40, 40), 40, Color(1, 0, 0, 0.3))
	draw_circle(_fire_button_rect.position + Vector2(40, 40), 30, Color(1, 0, 0, 0.5))
	
	# Рисуем кнопку рывка
	draw_circle(_dash_button_rect.position + Vector2(35, 35), 35, Color(0, 1, 0, 0.3))
	draw_circle(_dash_button_rect.position + Vector2(35, 35), 25, Color(0, 1, 0, 0.5))

func _draw_joystick(origin: Vector2, current: Vector2, range: float, color: Color) -> void:
	# Базовая зона джойстика
	draw_circle(origin, range, Color(color.r, color.g, color.b, 0.2))
	draw_circle(origin, 5, color)
	
	# Текущая позиция стика
	if current != Vector2.ZERO:
		var clamped_current = origin + (current - origin).clamped(range)
		draw_circle(clamped_current, 20, color)
