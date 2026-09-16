extends CanvasLayer

@onready var player_health: ProgressBar = $HUD/PlayerHealth
@onready var experience_bar: ProgressBar = $HUD/ExperienceBar
@onready var level_label: Label = $HUD/LevelLabel
@onready var level_up_panel: Panel = $HUD/LevelUpPanel
@onready var modifier_buttons: Array[Button] = [$HUD/LevelUpPanel/Modifier1, $HUD/LevelUpPanel/Modifier2, $HUD/LevelUpPanel/Modifier3]
@onready var game_over_panel: Panel = $HUD/GameOverPanel
@onready var game_over_label: Label = $HUD/GameOverPanel/Stats

var modifier_options := [
	{"id": "speed", "text": "Скорость +15%"},
	{"id": "damage", "text": "Урон +20%"},
	{"id": "health", "text": "Макс. HP +20 и лечение"}
]
var current_options: Array[Dictionary] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	level_up_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	for index in modifier_buttons.size():
		modifier_buttons[index].pressed.connect(_on_modifier_selected.bind(index))
	$HUD/GameOverPanel/RestartButton.pressed.connect(_restart_game)
	call_deferred("_connect_player")

func _connect_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_component.health_changed.connect(_update_player_health)
		player.experience_changed.connect(_update_experience)
		player.level_up.connect(_show_level_up)
		player.health_component.died.connect(_show_game_over)
		_update_player_health(player.health_component.current_health, player.health_component.max_health)
		_update_experience(player.experience, player.experience_to_next_level(), player.level)

func _show_level_up(_level: int) -> void:
	if game_over_panel.visible:
		return
	current_options = modifier_options.duplicate()
	current_options.shuffle()
	for index in modifier_buttons.size():
		modifier_buttons[index].text = current_options[index].text
	level_up_panel.visible = true
	get_tree().paused = true

func _on_modifier_selected(index: int) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and index < current_options.size():
		player.apply_modifier(current_options[index].id)
	level_up_panel.visible = false
	get_tree().paused = false

func _show_game_over() -> void:
	level_up_panel.visible = false
	var player := get_tree().get_first_node_in_group("player")
	var main := get_tree().current_scene
	var kills: int = int(main.get("kills")) if main else 0
	game_over_label.text = "Игра окончена\nУровень: %d\nУбийств: %d" % [player.level, kills]
	game_over_panel.visible = true
	get_tree().paused = true

func _restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _update_player_health(current: int, maximum: int) -> void:
	player_health.max_value = maximum
	player_health.value = current

func _update_experience(current: int, required: int, level: int) -> void:
	experience_bar.max_value = required
	experience_bar.value = current
	level_label.text = "Уровень: %d" % level