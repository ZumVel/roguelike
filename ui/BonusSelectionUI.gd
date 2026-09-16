extends Control
class_name BonusSelectionUI

@export var card_container: HBoxContainer
@export var card_scene: PackedScene
@export var title_label: Label

var level_up_component: LevelUpComponent = null
var is_visible_currently: bool = false

signal bonus_selected(bonus_id: String)

func _ready() -> void:
	visible = false

func show_bonus_selection(level_comp: LevelUpComponent) -> void:
	level_up_component = level_comp
	is_visible_currently = true
	
	if title_label:
		title_label.text = "Уровень %d! Выберите бонус:" % level_up_component.get_level()
	
	_clear_cards()
	
	var bonuses = level_up_component.generate_bonus_options(3)
	for bonus in bonuses:
		_create_card(bonus)
	
	visible = true
	get_tree().paused = true

func hide_bonus_selection() -> void:
	visible = false
	get_tree().paused = false
	is_visible_currently = false
	level_up_component = null

func _clear_cards() -> void:
	if card_container:
		for child in card_container.get_children():
			child.queue_free()

func _create_card(bonus_data: Dictionary) -> void:
	if not card_container or not card_scene:
		return
	
	var card = card_scene.instantiate()
	card_container.add_child(card)
	
	if card.has_method("setup"):
		var bonus_id = bonus_data.get("id", "")
		card.setup(bonus_data, bonus_id)
	
	if card.has_signal("card_selected"):
		card.card_selected.connect(_on_bonus_card_selected)

func _on_bonus_card_selected(bonus_id: String) -> void:
	bonus_selected.emit(bonus_id)
	if level_up_component:
		level_up_component.select_bonus(bonus_id)
	hide_bonus_selection()
