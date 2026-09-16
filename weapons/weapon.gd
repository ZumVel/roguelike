extends Area2D
class_name Weapon

@onready var damage_comp: DamageComponent = $DamageComponent
@onready var shoot_comp: ShootComponent = $ShootComponent
@onready var visual_comp: VisualComponent = $VisualComponent

func _process(delta: float) -> void:
	visual_comp.update_visual(delta)

	var mouse_pos := get_global_mouse_position()
	if mouse_pos.distance_squared_to(global_position) > 0.01:
		global_rotation = global_position.angle_to_point(mouse_pos)


func fire(target_position: Vector2) -> void:
	if shoot_comp.fire(target_position):
		visual_comp.trigger_muzzle()
