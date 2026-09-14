extends CharacterBody2D
class_name Player

@onready var input_component:   InputComponent   = $InputComponent
@onready var movement_component:MovementComponent = $MovementComponent
@onready var weapon = $weapon/ShootComponent

func _physics_process(delta: float) -> void:
	movement_component.move(input_component.get_input_vector(), delta)
	if input_component.is_firing():
		var aim_dir := input_component.get_aim_direction(global_position)
		weapon.fire(global_position + aim_dir * 1000)
