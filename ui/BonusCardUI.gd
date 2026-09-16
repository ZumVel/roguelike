extends Control
class_name BonusCardUI

@export var card_name_label: Label
@export var card_description_label: Label
@export var card_icon: TextureRect

var bonus_data: Dictionary = {}
var bonus_id: String = ""

signal card_selected(id: String)

func _ready() -> void:
	pass

func setup(data: Dictionary, id: String) -> void:
	bonus_data = data
	bonus_id = id
	
	if card_name_label:
		card_name_label.text = data.get("name", "Unknown Bonus")
	if card_description_label:
		card_description_label.text = data.get("description", "")

func _on_card_pressed() -> void:
	card_selected.emit(bonus_id)
