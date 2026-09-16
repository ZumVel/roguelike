extends CharacterBody2D
class_name Player

@onready var input_component:   InputComponent   = $InputComponent
@onready var movement_component:MovementComponent = $MovementComponent
@onready var weapon = $weapon/ShootComponent
@onready var dash_component: DashComponent = $DashComponent
@onready var level_up_component: LevelUpComponent = $LevelUpComponent

var _xp_collected: int = 0

func _ready() -> void:
	add_to_group("player")
	
	if level_up_component:
		level_up_component.level_up_requested.connect(_on_level_up)

func _physics_process(delta: float) -> void:
	var input_dir = input_component.get_input_vector()
	
	if input_component.is_dashing() and dash_component:
		var dash_dir = input_dir
		if dash_dir == Vector2.ZERO:
			dash_dir = get_last_movement_direction()
		dash_component.start_dash(dash_dir)
	
	movement_component.move(input_dir, delta)
	
	if input_component.is_firing():
		var aim_dir := input_component.get_aim_direction(global_position)
		weapon.fire(global_position + aim_dir * 1000)

func get_last_movement_direction() -> Vector2:
	if movement_component.body.velocity != Vector2.ZERO:
		return movement_component.body.velocity.normalized()
	return Vector2.RIGHT

func collect_xp(amount: int) -> void:
	if level_up_component:
		level_up_component.add_xp(amount)

func _on_level_up(new_level: int) -> void:
	print("Level up! New level: ", new_level)
	var bonus_ui = get_tree().current_scene.get_node_or_null("BonusSelectionUI") as BonusSelectionUI
	if bonus_ui:
		bonus_ui.show_bonus_selection(level_up_component)
