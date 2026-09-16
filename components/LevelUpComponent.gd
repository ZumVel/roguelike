extends Node
class_name LevelUpComponent

signal level_up_requested(current_level: int)
signal bonus_selected(bonus_id: String)

@export var start_xp_required: int = 100
@export var xp_scaling_factor: float = 1.5

var current_level: int = 1
var current_xp: int = 0
var xp_required: int = 100

var available_bonuses: Array[Dictionary] = []

func _ready() -> void:
	xp_required = start_xp_required

func add_xp(amount: int) -> void:
	current_xp += amount
	
	while current_xp >= xp_required:
		current_xp -= xp_required
		current_level += 1
		xp_required = int(xp_required * xp_scaling_factor)
		level_up_requested.emit(current_level)

func get_level() -> int:
	return current_level

func get_xp_progress() -> float:
	if xp_required == 0:
		return 1.0
	return float(current_xp) / float(xp_required)

func generate_bonus_options(count: int = 3) -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	var bonus_templates = _get_bonus_templates()
	
	for i in range(count):
		if bonus_templates.is_empty():
			break
		
		var random_index = randi() % bonus_templates.size()
		var bonus = bonus_templates[random_index].duplicate()
		bonus["id"] = "bonus_%d_%d" % [current_level, i]
		options.append(bonus)
		bonus_templates.remove_at(random_index)
	
	available_bonuses = options
	return options

func select_bonus(bonus_id: String) -> void:
	for bonus in available_bonuses:
		if bonus["id"] == bonus_id:
			bonus_selected.emit(bonus_id)
			_apply_bonus(bonus)
			break

func _apply_bonus(bonus: Dictionary) -> void:
	print("Applying bonus: ", bonus.get("name", "Unknown"))

func _get_bonus_templates() -> Array[Dictionary]:
	return [
		{"name": "Увеличить урон", "type": "damage", "value": 1.2, "description": "+20% к урону"},
		{"name": "Увеличить скорость", "type": "speed", "value": 1.15, "description": "+15% к скорости"},
		{"name": "Уменьшить перезарядку", "type": "fire_rate", "value": 0.8, "description": "-20% к перезарядке"},
		{"name": "Увеличить здоровье", "type": "health", "value": 25, "description": "+25 HP"},
		{"name": "Рывок быстрее", "type": "dash_speed", "value": 1.3, "description": "+30% к скорости рывка"}
	]
