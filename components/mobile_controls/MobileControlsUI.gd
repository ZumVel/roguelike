extends CanvasLayer
class_name MobileControlsUI

## Ссылка на компонент ввода
@export var mobile_input: MobileInputComponent

## UI элементы (ссылки на узлы из сцены)
@onready var move_joystick_bg: TextureRect = $MoveJoystickBG
@onready var move_joystick_stick: TextureRect = $MoveJoystickBG/MoveJoystickStick
@onready var aim_joystick_bg: TextureRect = $AimJoystickBG
@onready var aim_joystick_stick: TextureRect = $AimJoystickBG/AimJoystickStick
@onready var fire_button: TouchScreenButton = $FireButton
@onready var dash_button: TouchScreenButton = $DashButton

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
	move_joystick_bg.visible = true
	move_joystick_stick.visible = true
	aim_joystick_bg.visible = true
	aim_joystick_stick.visible = true
	fire_button.visible = true
	dash_button.visible = true
	
	# Подключаем сигналы кнопок
	fire_button.pressed.connect(_on_fire_pressed)
	fire_button.released.connect(_on_fire_released)
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
