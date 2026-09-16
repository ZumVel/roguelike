extends Node
class_name VisualComponent

@export var muzzle_flash: PackedScene
@export var recoil_amount: float = 4.0
@export var max_recoil: float = 10.0
@export var recover_speed: float = 60.0
@export var flash_lifetime: float = 0.06

var _rest_pos: Vector2

func _ready() -> void:
	_rest_pos = get_parent().position


func update_visual(delta: float) -> void:
	var weapon := get_parent() as Node2D
	if weapon == null:
		return
	weapon.position = weapon.position.move_toward(_rest_pos, recover_speed * delta)


func trigger_muzzle() -> void:
	var weapon := get_parent() as Node2D
	if weapon == null:
		return

	if muzzle_flash:
		var fx := muzzle_flash.instantiate() as Node2D
		weapon.add_child(fx)
		var muzzle := weapon.get_node_or_null("muzzle") as Node2D
		if muzzle:
			fx.global_position = muzzle.global_position
		else:
			fx.global_position = weapon.global_position
		# Flash must disappear — otherwise it looks like a stuck bullet
		get_tree().create_timer(flash_lifetime).timeout.connect(fx.queue_free)

	# Kick back along the barrel, then clamp so it can't fly off the player
	var kick := Vector2.LEFT.rotated(weapon.rotation) * recoil_amount
	weapon.position += kick
	var offset := weapon.position - _rest_pos
	if offset.length() > max_recoil:
		weapon.position = _rest_pos + offset.limit_length(max_recoil)
