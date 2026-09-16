extends CharacterBody2D
class_name Player

signal experience_changed(current: int, required: int, level: int)
signal level_up(level: int)

@onready var input_component: InputComponent = $InputComponent
@onready var movement_component: MovementComponent = $MovementComponent
@onready var weapon: Weapon = $weapon
@onready var health_component: Node = $HealthComponent

var level := 1
var experience := 0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	movement_component.move(input_component.get_input_vector(), delta)
	if input_component.is_firing():
		weapon.fire(get_global_mouse_position())

func add_experience(amount: int) -> void:
	experience += amount
	while experience >= experience_to_next_level():
		experience -= experience_to_next_level()
		level += 1
		health_component.restore_fraction(0.1)
		level_up.emit(level)
	experience_changed.emit(experience, experience_to_next_level(), level)

func apply_modifier(modifier: String) -> void:
	match modifier:
		"speed":
			movement_component.speed *= 1.15
		"damage":
			weapon.damage_comp.damage = int(round(weapon.damage_comp.damage * 1.2))
		"health":
			health_component.max_health += 20
			health_component.restore_fraction(0.2)

func experience_to_next_level() -> int:
	return 100 + (level - 1) * 50
