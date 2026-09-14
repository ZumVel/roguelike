extends Node
class_name VisualComponent

@export var muzzle_flash: PackedScene             
@export var recoil_amount: float = 5.0             
var _original_pos: Vector2

func _ready() -> void:
	_original_pos = get_parent().position

func update_visual(delta: float) -> void:
	var owner = get_parent()
	owner.position = owner.position.move_toward(_original_pos, recoil_amount * delta)

func trigger_muzzle() -> void:
	if muzzle_flash:
		var fx = muzzle_flash.instantiate()
		get_parent().add_child(fx)
		fx.global_position = get_parent().global_position
	
	var owner = get_parent()
	owner.position.x -= recoil_amount
