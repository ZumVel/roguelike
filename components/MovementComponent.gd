extends Node
class_name MovementComponent

@export var speed: float = 200.0          # пикселей/секунда
@export var acceleration: float = 800.0  # пикселей/сек²
@export var friction: float = 1200.0      # пикселей/сек²

var body: CharacterBody2D

func _ready() -> void:
	body = get_parent() as CharacterBody2D
	if not body:
		push_error("MovementComponent должен быть дочерним узлом CharacterBody2D")

func move(direction: Vector2, delta: float) -> void:
	if direction != Vector2.ZERO:
		body.velocity = body.velocity.move_toward(direction * speed, acceleration * delta)
	else:
		body.velocity = body.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	body.move_and_slide()
