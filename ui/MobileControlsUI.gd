extends Control
class_name MobileControlsUI

@export var move_joystick: VirtualJoystick
@export var aim_joystick: VirtualJoystick
@export var dash_button: Button

var _is_mobile: bool = false

func _ready() -> void:
	_is_mobile = OS.get_name() in ["Android", "iOS"]
	visible = _is_mobile
	
	if not _is_mobile:
		set_process(false)
		return
	
	# Поиск джойстиков и кнопки как дочерних элементов
	if not move_joystick:
		move_joystick = $MoveJoystickContainer/MoveJoystick as VirtualJoystick
	if not aim_joystick:
		aim_joystick = $AimJoystickContainer/AimJoystick as VirtualJoystick
	if not dash_button:
		dash_button = $DashButton as Button
	
	if move_joystick:
		move_joystick.vector_changed.connect(_on_move_vector_changed)
	if aim_joystick:
		aim_joystick.vector_changed.connect(_on_aim_vector_changed)
	if dash_button:
		dash_button.pressed.connect(_on_dash_pressed)

func _on_move_vector_changed(vector: Vector2) -> void:
	var input_comp = _get_input_component()
	if input_comp:
		input_comp.set_mobile_move_vector(vector)

func _on_aim_vector_changed(vector: Vector2) -> void:
	var input_comp = _get_input_component()
	if input_comp:
		input_comp.set_mobile_aim_vector(vector)

func _on_dash_pressed() -> void:
	var input_comp = _get_input_component()
	if input_comp:
		input_comp.trigger_mobile_dash()

func _get_input_component() -> InputComponent:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_parent().get_node_or_null("../SimpleCharacter")
	if not player:
		player = get_tree().current_scene.get_node_or_null("SimpleCharacter")
	
	if player and player.has_node("InputComponent"):
		return player.get_node("InputComponent") as InputComponent
	
	return null
