extends Area2D
class_name Weapon

@onready var damage_comp: DamageComponent = $DamageComponent
@onready var shoot_comp:   ShootComponent   = $ShootComponent
@onready var visual_comp:  VisualComponent  = $VisualComponent

func _process(delta: float) -> void:
	visual_comp.update_visual(delta)
	
	# Поворот пушки за мышкой
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	if direction != Vector2.ZERO:
		look_at(mouse_pos)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_ENTER):
		var mouse_pos = get_global_mouse_position()
		fire(mouse_pos)

func fire(target_position: Vector2) -> void:
	shoot_comp.fire(target_position)
	
	visual_comp.trigger_muzzle()
