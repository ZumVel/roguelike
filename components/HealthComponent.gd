extends Node
class_name HealthComponent

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100
var current_health: int

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func receive_damage(amount: int, _knockback: float = 0.0) -> void:
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()

func restore_fraction(fraction: float) -> void:
	current_health = min(current_health + int(round(max_health * fraction)), max_health)
	health_changed.emit(current_health, max_health)

func get_health_ratio() -> float:
	return float(current_health) / float(max_health)