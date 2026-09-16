extends Node
class_name MovementComponent

@export var speed: float = 200.0          # пикселей/секунда
@export var acceleration: float = 800.0  # пикселей/сек²
@export var friction: float = 1200.0      # пикселей/сек²

var body: CharacterBody2D
var dash_component: DashComponent = null

func _ready() -> void:
	body = get_parent() as CharacterBody2D
	if not body:
		push_error("MovementComponent должен быть дочерним узлом CharacterBody2D")
	
	dash_component = body.get_node_or_null("DashComponent")

func move(direction: Vector2, delta: float) -> void:
	var final_velocity := Vector2.ZERO
	
	if dash_component and dash_component.is_dashing():
		final_velocity = dash_component.get_dash_velocity()
	else:
		if direction != Vector2.ZERO:
			body.velocity = body.velocity.move_toward(direction * speed, acceleration * delta)
		else:
			body.velocity = body.velocity.move_toward(Vector2.ZERO, friction * delta)
		final_velocity = body.velocity
	
	body.velocity = final_velocity
	body.move_and_slide()
