extends Node
class_name MobileControlsController

## Этот компонент связывает MobileInputComponent и DashComponent
## Должен быть добавлен как дочерний узел игрока (CharacterBody2D)

var mobile_input: MobileInputComponent
var dash_component: DashComponent
var input_component: InputComponent

func _ready() -> void:
	# Находим компоненты на родителе
	var parent = get_parent()
	
	mobile_input = parent.get_node_or_null("InputComponent/MobileInputComponent") as MobileInputComponent
	dash_component = parent.get_node_or_null("DashComponent") as DashComponent
	input_component = parent.get_node_or_null("InputComponent") as InputComponent
	
	if mobile_input:
		# Подключаем сигнал рывка от мобильного ввода к компоненту рывка
		mobile_input.dash_requested.connect(_on_dash_requested)
		
		# Подключаем сигналы огня для стрельбы
		mobile_input.fire_started.connect(_on_fire_started)
		mobile_input.fire_ended.connect(_on_fire_ended)

func _on_dash_requested() -> void:
	if dash_component and input_component:
		# Определяем направление рывка
		var direction = Vector2.ZERO
		
		# Приоритет 1: направление прицеливания (если активно)
		var aim_vector = mobile_input.get_aim_vector()
		if aim_vector != Vector2.ZERO:
			direction = aim_vector
		else:
			# Приоритет 2: направление движения
			var move_vector = mobile_input.get_move_vector()
			if move_vector != Vector2.ZERO:
				direction = move_vector
			else:
				# Приоритет 3: последнее известное направление или дефолтное
				direction = Vector2.RIGHT
		
		dash_component.request_dash(direction)

var _is_firing_mobile: bool = false

func _on_fire_started() -> void:
	_is_firing_mobile = true

func _on_fire_ended() -> void:
	_is_firing_mobile = false

func is_mobile_firing() -> bool:
	return _is_firing_mobile
