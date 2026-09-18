extends CanvasLayer
class_name MobileControlsUI

## Ссылка на компонент ввода
@export var mobile_input: MobileInputComponent

## UI элементы
var move_joystick_bg: TextureRect
var move_joystick_stick: TextureRect
var aim_joystick_bg: TextureRect
var aim_joystick_stick: TextureRect
var fire_button: TouchScreenButton
var dash_button: TouchScreenButton

## Иконки (будут созданы программно)
var joystick_bg_texture: Texture2D
var joystick_stick_texture: Texture2D
var fire_button_texture: Texture2D
var dash_button_texture: Texture2D

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
	
	_create_textures()
	_create_ui_elements()
	
	# Обновляем UI при изменении размера окна
	get_viewport().size_changed.connect(_update_ui_positions)
	_update_ui_positions()

func _is_mobile_device() -> bool:
	if OS.get_name() in ["Android", "iOS"]:
		return true
	if DisplayServer.is_touchscreen_available():
		return true
	return false

func _create_textures() -> void:
	# Создаем текстуру фона джойстика (круг с полупрозрачным цветом)
	var bg_image = Image.create(100, 100, false, Image.FORMAT_RGBA8)
	bg_image.fill(Color(0, 0.3, 0.6, 0.3))
	_draw_circle_on_image(bg_image, Color(0, 0.3, 0.6, 0.2), 50)
	joystick_bg_texture = ImageTexture.create_from_image(bg_image)
	
	# Создаем текстуру стика джойстика
	var stick_image = Image.create(50, 50, false, Image.FORMAT_RGBA8)
	stick_image.fill(Color(0, 0.5, 1, 0.8))
	_draw_circle_on_image(stick_image, Color(1, 1, 1, 0.5), 25)
	joystick_stick_texture = ImageTexture.create_from_image(stick_image)
	
	# Создаем текстуру кнопки огня (красная)
	var fire_image = Image.create(80, 80, false, Image.FORMAT_RGBA8)
	fire_image.fill(Color(1, 0, 0, 0.3))
	_draw_circle_on_image(fire_image, Color(1, 0, 0, 0.7), 40)
	_draw_circle_on_image(fire_image, Color(1, 1, 1, 0.8), 15)
	fire_button_texture = ImageTexture.create_from_image(fire_image)
	
	# Создаем текстуру кнопки рывка (зеленая с молнией)
	var dash_image = Image.create(70, 70, false, Image.FORMAT_RGBA8)
	dash_image.fill(Color(0, 1, 0, 0.3))
	_draw_circle_on_image(dash_image, Color(0, 1, 0, 0.7), 35)
	_draw_lightning_on_image(dash_image, Color(1, 1, 1, 0.9), 35)
	dash_button_texture = ImageTexture.create_from_image(dash_image)

func _draw_circle_on_image(image: Image, color: Color, radius: int) -> void:
	var center = Vector2(image.get_width() / 2, image.get_height() / 2)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pos = Vector2(x, y)
			if pos.distance_to(center) <= radius:
				image.set_pixel(x, y, color)

func _draw_lightning_on_image(image: Image, color: Color, size: float) -> void:
	var center = Vector2(image.get_width() / 2, image.get_height() / 2)
	var points = [
		center + Vector2(-size * 0.3, -size * 0.8),
		center + Vector2(size * 0.5, -size * 0.2),
		center + Vector2(size * 0.1, -size * 0.2),
		center + Vector2(size * 0.4, size * 0.8),
		center + Vector2(-size * 0.5, size * 0.1),
		center + Vector2(-size * 0.1, size * 0.1)
	]
	_draw_polygon_on_image(image, points, color)

func _draw_polygon_on_image(image: Image, points: Array, color: Color) -> void:
	if points.size() < 3:
		return
	
	# Простая триангуляция для заполнения полигона
	var min_x = image.get_width()
	var max_x = 0
	var min_y = image.get_height()
	var max_y = 0
	
	for point in points:
		min_x = mini(min_x, int(point.x))
		max_x = maxi(max_x, int(point.x))
		min_y = mini(min_y, int(point.y))
		max_y = maxi(max_y, int(point.y))
	
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if _point_in_polygon(Vector2(x, y), points):
				image.set_pixel(x, y, color)

func _point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var inside = false
	var j = polygon.size() - 1
	
	for i in range(polygon.size()):
		var pi = polygon[i] as Vector2
		var pj = polygon[j] as Vector2
		
		if ((pi.y > point.y) != (pj.y > point.y)) and \
		   (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x):
			inside = !inside
		
		j = i
	
	return inside

func _create_ui_elements() -> void:
	# Очищаем существующие элементы
	for child in get_children():
		child.queue_free()
	
	# Левый джойстик (движение)
	move_joystick_bg = TextureRect.new()
	move_joystick_bg.name = "MoveJoystickBG"
	move_joystick_bg.texture = joystick_bg_texture
	move_joystick_bg.custom_minimum_size = Vector2(100, 100)
	add_child(move_joystick_bg)
	
	move_joystick_stick = TextureRect.new()
	move_joystick_stick.name = "MoveJoystickStick"
	move_joystick_stick.texture = joystick_stick_texture
	move_joystick_stick.custom_minimum_size = Vector2(50, 50)
	move_joystick_bg.add_child(move_joystick_stick)
	
	# Правый джойстик (прицеливание)
	aim_joystick_bg = TextureRect.new()
	aim_joystick_bg.name = "AimJoystickBG"
	aim_joystick_bg.texture = joystick_bg_texture
	aim_joystick_bg.custom_minimum_size = Vector2(100, 100)
	add_child(aim_joystick_bg)
	
	aim_joystick_stick = TextureRect.new()
	aim_joystick_stick.name = "AimJoystickStick"
	aim_joystick_stick.texture = joystick_stick_texture
	aim_joystick_stick.custom_minimum_size = Vector2(50, 50)
	aim_joystick_bg.add_child(aim_joystick_stick)
	
	# Кнопка огня
	fire_button = TouchScreenButton.new()
	fire_button.name = "FireButton"
	fire_button.shape = CircleShape2D.new()
	fire_button.shape.radius = 40
	var fire_texture_rect = TextureRect.new()
	fire_texture_rect.texture = fire_button_texture
	fire_texture_rect.custom_minimum_size = Vector2(80, 80)
	fire_button.add_child(fire_texture_rect)
	fire_button.pressed.connect(_on_fire_pressed)
	fire_button.released.connect(_on_fire_released)
	add_child(fire_button)
	
	# Кнопка рывка
	dash_button = TouchScreenButton.new()
	dash_button.name = "DashButton"
	dash_button.shape = CircleShape2D.new()
	dash_button.shape.radius = 35
	var dash_texture_rect = TextureRect.new()
	dash_texture_rect.texture = dash_button_texture
	dash_texture_rect.custom_minimum_size = Vector2(70, 70)
	dash_button.add_child(dash_texture_rect)
	dash_button.pressed.connect(_on_dash_pressed)
	add_child(dash_button)

func _update_ui_positions() -> void: 
	var viewport_size = get_viewport().size
	
	# Позиция левого джойстика (снизу слева)
	var move_origin = mobile_input.get_move_joystick_position()
	var move_pos = Vector2()
	if move_origin.x > 0:
		move_pos = Vector2(move_origin.x - 50, viewport_size.y + move_origin.y - 50)
	else:
		move_pos = Vector2(viewport_size.x + move_origin.x - 50, viewport_size.y + move_origin.y - 50)
	move_joystick_bg.position = move_pos
	
	# Позиция правого джойстика (снизу справа)
	var aim_origin = mobile_input.get_aim_joystick_position()
	var aim_pos = Vector2()
	if aim_origin.x > 0:
		aim_pos = Vector2(aim_origin.x - 50, viewport_size.y + aim_origin.y - 50)
	else:
		aim_pos = Vector2(viewport_size.x + aim_origin.x - 50, viewport_size.y + aim_origin.y - 50)
	aim_joystick_bg.position = aim_pos
	
	# Позиция кнопки огня
	var fire_origin = mobile_input.get_fire_button_position()
	var fire_pos = Vector2()
	if fire_origin.x > 0:
		fire_pos = Vector2(fire_origin.x, viewport_size.y + fire_origin.y)
	else:
		fire_pos = Vector2(viewport_size.x + fire_origin.x, viewport_size.y + fire_origin.y)
	fire_button.position = fire_pos
	
	# Позиция кнопки рывка
	var dash_origin = mobile_input.get_dash_button_position()
	var dash_pos = Vector2()
	if dash_origin.x > 0:
		dash_pos = Vector2(dash_origin.x, viewport_size.y + dash_origin.y)
	else:
		dash_pos = Vector2(viewport_size.x + dash_origin.x, viewport_size.y + dash_origin.y)
	dash_button.position = dash_pos

func _process(_delta: float) -> void:
	if not visible or not mobile_input:
		return
	
	# Обновляем позицию стика левого джойстика
	var move_vec = mobile_input.get_move_vector()
	move_joystick_stick.position = move_vec * 25  # Смещение стика
	
	# Обновляем позицию стика правого джойстика
	var aim_vec = mobile_input.get_aim_vector()
	aim_joystick_stick.position = aim_vec * 25  # Смещение стика

func _on_fire_pressed() -> void:
	if mobile_input:
		mobile_input.fire_started.emit()

func _on_fire_released() -> void:
	if mobile_input:
		mobile_input.fire_ended.emit()

func _on_dash_pressed() -> void:
	if mobile_input:
		mobile_input.dash_requested.emit()
