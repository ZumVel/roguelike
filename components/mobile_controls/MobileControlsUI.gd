extends CanvasLayer
class_name MobileControlsUI

## Ссылка на компонент ввода
@export var mobile_input: MobileInputComponent

## UI элементы (ссылки на узлы из сцены) - задаются через export
@export var move_joystick_bg: TextureRect
@export var move_joystick_stick: TextureRect
@export var aim_joystick_bg: TextureRect
@export var aim_joystick_stick: TextureRect
@export var fire_button: TouchScreenButton
@export var dash_button: TouchScreenButton

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
	
	# Показываем UI элементы
	if move_joystick_bg:
		move_joystick_bg.visible = true
	if move_joystick_stick:
		move_joystick_stick.visible = true
	if aim_joystick_bg:
		aim_joystick_bg.visible = true
	if aim_joystick_stick:
		aim_joystick_stick.visible = true
	if fire_button:
		fire_button.visible = true
	if dash_button:
		dash_button.visible = true
	
	# Подключаем сигналы кнопок
	if fire_button:
		fire_button.pressed.connect(_on_fire_pressed)
		fire_button.released.connect(_on_fire_released)
	if dash_button:
		dash_button.pressed.connect(_on_dash_pressed)
	
	# Обновляем UI при изменении размера окна
	get_viewport().size_changed.connect(_update_ui_positions)
	_update_ui_positions()

func _is_mobile_device() -> bool:
	if OS.get_name() in ["Android", "iOS"]:
		return true
	if DisplayServer.is_touchscreen_available():
		return true
	return false

func _update_ui_positions() -> void: 
	var viewport_size = get_viewport().size
	
	# Позиция левого джойстика (снизу слева)
	if mobile_input and move_joystick_bg:
		var move_origin = mobile_input.get_move_joystick_position()
		var move_pos = Vector2()
		if move_origin.x > 0:
			move_pos = Vector2(move_origin.x - 50, viewport_size.y + move_origin.y - 50)
		else:
			move_pos = Vector2(viewport_size.x + move_origin.x - 50, viewport_size.y + move_origin.y - 50)
		move_joystick_bg.position = move_pos
	
	# Позиция правого джойстика (снизу справа)
	if mobile_input and aim_joystick_bg:
		var aim_origin = mobile_input.get_aim_joystick_position()
		var aim_pos = Vector2()
		if aim_origin.x > 0:
			aim_pos = Vector2(aim_origin.x - 50, viewport_size.y + aim_origin.y - 50)
		else:
			aim_pos = Vector2(viewport_size.x + aim_origin.x - 50, viewport_size.y + aim_origin.y - 50)
		aim_joystick_bg.position = aim_pos
	
	# Позиция кнопки огня
	if mobile_input and fire_button:
		var fire_origin = mobile_input.get_fire_button_position()
		var fire_pos = Vector2()
		if fire_origin.x > 0:
			fire_pos = Vector2(fire_origin.x, viewport_size.y + fire_origin.y)
		else:
			fire_pos = Vector2(viewport_size.x + fire_origin.x, viewport_size.y + fire_origin.y)
		fire_button.position = fire_pos
	
	# Позиция кнопки рывка
	if mobile_input and dash_button:
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
	if move_joystick_stick:
		var move_vec = mobile_input.get_move_vector()
		move_joystick_stick.position = move_vec * 25  # Смещение стика
	
	# Обновляем позицию стика правого джойстика
	if aim_joystick_stick:
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
