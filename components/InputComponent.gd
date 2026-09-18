extends Node2D
class_name InputComponent

@export var up_action:   String = "ui_up"
@export var down_action: String = "ui_down"
@export var left_action: String = "ui_left"
@export var right_action:String = "ui_right"

@export var fire_action: String = "ui_accept"

## Ссылка на компонент мобильного ввода (опционально)
var mobile_input: MobileInputComponent = null
var mobile_controller: MobileControlsController = null

func _ready() -> void:
	# Пытаемся найти дочерний узел MobileInputComponent
	mobile_input = get_node_or_null("MobileInputComponent") as MobileInputComponent
	
	# Пытаемся найти родительский контроллер мобильных элементов управления
	var parent = get_parent()
	if parent and parent.has_node("MobileControlsController"):
		mobile_controller = parent.get_node("MobileControlsController") as MobileControlsController

func get_input_vector() -> Vector2:
	var dir := Vector2.ZERO
	
	# Если мобильное устройство и есть mobile_input, используем его
	if mobile_input and _is_mobile_device():
		dir = mobile_input.get_move_vector()
	else:
		dir.x = Input.get_action_strength(right_action) - Input.get_action_strength(left_action)
		dir.y = Input.get_action_strength(down_action) - Input.get_action_strength(up_action)
	
	return dir.normalized()

func _get_mouse_world_position() -> Vector2:
	return get_global_mouse_position()

func get_aim_direction(origin: Vector2) -> Vector2:
	# Если мобильное устройство и есть mobile_input, используем джойстик прицеливания
	if mobile_input and _is_mobile_device():
		var aim_vector = mobile_input.get_aim_vector()
		if aim_vector != Vector2.ZERO:
			return aim_vector
		# Если джойстик не активен, возвращаем последнее направление или дефолтное
		return Vector2.RIGHT
	
	var mouse_pos := _get_mouse_world_position()
	var dir := mouse_pos - origin
	return dir.normalized()

func is_firing() -> bool:
	# Проверяем мобильный ввод через контроллер
	if mobile_controller and _is_mobile_device():
		return mobile_controller.is_mobile_firing()
	
	# Проверяем мобильный ввод напрямую (для обратной совместимости)
	if mobile_input and _is_mobile_device():
		return mobile_input.is_firing()
	
	return Input.is_action_pressed(fire_action) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func _is_mobile_device() -> bool:
	if OS.get_name() in ["Android", "iOS"]:
		return true
	if Input.has_touchscreen_ui_hint():
		return true
	return false
