extends Node
class_name DamageComponent

@export var damage: int = 10
@export var knockback: float = 200.0

func apply(target: Node) -> void:
	if target.has_method("receive_damage"):
		target.receive_damage(damage, knockback)
