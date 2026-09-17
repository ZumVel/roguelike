extends CanvasLayer
class_name MobileControlsUI

## Ссылка на компонент ввода
@export var mobile_input: MobileInputComponent

## Цвета элементов
@export var move_joystick_color: Color = Color(0, 0.5, 1, 0.5)
@export var aim_joystick_color: Color = Color(1, 0.5, 0, 0.5)
@export var fire_button_color: Color = Color(1, 0, 0, 0.5)
@export var dash_button_color: Color = Color(0, 1, 0, 0.5)

## Размеры
@export var move_joystick_base_radius: float = 50.0
@export var aim_joystick_base_radius: float = 50.0
@export var fire_button_radius: float = 40.0
@export var dash_button_radius: float = 35.0
@export var stick_radius: float = 20.0

func _ready() -> void:
	if not mobile_input:
		mobile_input = get_node_or_null("../InputComponent/MobileInputComponent")
	
	# Проверяем, запущено ли на мобильном устройстве
	if not _is_mobile_device():
		visible = false
		set_process(false)
		return
	
	visible = true
	layer = 100  # Поверх всего
	
	# Обновляем UI при изменении размера окна
	get_viewport().size_changed.connect(queue_redraw)

func _is_mobile_device() -> bool:
	if OS.get_name() in ["Android", "iOS"]:
		return true
	if Input.has_touchscreen_ui_hint():
		return true
	return false

func _draw() -> void:
	if not visible or not mobile_input:
		return
	
	var viewport_size = get_viewport_rect().size
	
	# Получаем позиции из mobile_input через публичные методы
	var move_origin = _get_move_joystick_origin(viewport_size)
	var aim_origin = _get_aim_joystick_origin(viewport_size)
	var fire_pos = _get_fire_button_center(viewport_size)
	var dash_pos = _get_dash_button_center(viewport_size)
	
	# Рисуем джойстик движения
	_draw_joystick(move_origin, mobile_input.get_move_vector() * move_joystick_base_radius, move_joystick_base_radius, move_joystick_color)
	
	# Рисуем джойстик прицеливания
	_draw_joystick(aim_origin, mobile_input.get_aim_vector() * aim_joystick_base_radius, aim_joystick_base_radius, aim_joystick_color)
	
	# Рисуем кнопку огня
	draw_circle(fire_pos, fire_button_radius, Color(fire_button_color.r, fire_button_color.g, fire_button_color.b, 0.3))
	draw_circle(fire_pos, fire_button_radius * 0.75, fire_button_color)
	# Иконка огня (круг с точкой)
	draw_circle(fire_pos, fire_button_radius * 0.3, Color(1, 1, 1, 0.8))
	
	# Рисуем кнопку рывка
	draw_circle(dash_pos, dash_button_radius, Color(dash_button_color.r, dash_button_color.g, dash_button_color.b, 0.3))
	draw_circle(dash_pos, dash_button_radius * 0.75, dash_button_color)
	# Иконка рывка (молния)
	_draw_dash_icon(dash_pos, dash_button_radius * 0.5)

func _draw_joystick(origin: Vector2, stick_offset: Vector2, base_radius: float, color: Color) -> void:
	# Базовая зона
	draw_circle(origin, base_radius, Color(color.r, color.g, color.b, 0.2))
	draw_circle(origin, 5, color)
	
	# Стик
	var stick_pos = origin + stick_offset.clamped(base_radius)
	draw_circle(stick_pos, stick_radius, color)
	draw_circle(stick_pos, stick_radius * 0.6, Color(1, 1, 1, 0.5))

func _draw_dash_icon(center: Vector2, size: float) -> void:
	# Простая молния
	var points = [
		center + Vector2(-size * 0.3, -size * 0.8),
		center + Vector2(size * 0.5, -size * 0.2),
		center + Vector2(size * 0.1, -size * 0.2),
		center + Vector2(size * 0.4, size * 0.8),
		center + Vector2(-size * 0.5, size * 0.1),
		center + Vector2(-size * 0.1, size * 0.1)
	]
	draw_colored_polygon(points, Color(1, 1, 1, 0.9))

func _get_move_joystick_origin(viewport_size: Vector2) -> Vector2:
	var pos = mobile_input.get_move_joystick_position()
	if pos.x > 0:
		return Vector2(pos.x, viewport_size.y + pos.y)
	else:
		return Vector2(viewport_size.x + pos.x, viewport_size.y + pos.y)

func _get_aim_joystick_origin(viewport_size: Vector2) -> Vector2:
	var pos = mobile_input.get_aim_joystick_position()
	if pos.x > 0:
		return Vector2(pos.x, viewport_size.y + pos.y)
	else:
		return Vector2(viewport_size.x + pos.x, viewport_size.y + pos.y)

func _get_fire_button_center(viewport_size: Vector2) -> Vector2:
	var pos = mobile_input.get_fire_button_position()
	if pos.x > 0:
		return Vector2(pos.x, viewport_size.y + pos.y)
	else:
		return Vector2(viewport_size.x + pos.x, viewport_size.y + pos.y)

func _get_dash_button_center(viewport_size: Vector2) -> Vector2:
	var pos = mobile_input.get_dash_button_position()
	if pos.x > 0:
		return Vector2(pos.x, viewport_size.y + pos.y)
	else:
		return Vector2(viewport_size.x + pos.x, viewport_size.y + pos.y)
