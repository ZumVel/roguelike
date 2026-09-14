extends Area2D
class_name Weapon

@onready var damage_comp: DamageComponent = $DamageComponent
@onready var shoot_comp:   ShootComponent   = $ShootComponent
@onready var visual_comp:  VisualComponent  = $VisualComponent

func _process(delta: float) -> void:
	visual_comp.update_visual(delta)

func fire(target_position: Vector2) -> void:
	shoot_comp.fire(target_position)
	
	visual_comp.trigger_muzzle()
