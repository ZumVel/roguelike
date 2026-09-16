extends Node2D

@export var enemy_scene: PackedScene
@export var initial_enemy_count: int = 4
@export var wave_delay: float = 3.0

var wave_number := 1
var kills := 0
var spawning_wave := false
var spawn_timer: Timer
var random := RandomNumberGenerator.new()
const MIN_SPAWN_DISTANCE := 504.0
const EXTRA_SPAWN_DISTANCE := 260.0
const SPAWN_MIN := Vector2(-594.0, -125.0)
const SPAWN_MAX := Vector2(1726.0, 795.0)

func _ready() -> void:
	random.randomize()
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_spawn_next_wave)
	add_child(spawn_timer)
	_place_initial_enemies()
	_update_wave_label()

func _process(_delta: float) -> void:
	if not spawning_wave and get_tree().get_nodes_in_group("enemies").is_empty():
		spawning_wave = true
		spawn_timer.start(wave_delay)

func _spawn_next_wave() -> void:
	wave_number += 1
	var enemy_count := initial_enemy_count + wave_number - 1
	for index in enemy_count:
		var enemy := enemy_scene.instantiate()
		add_child(enemy)
		enemy.is_shooter = wave_number >= 5 and index % 3 == 0
		enemy.global_position = _spawn_position(index, enemy_count)
	spawning_wave = false
	_update_wave_label()

func _spawn_position(index: int, total: int) -> Vector2:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var center := player.global_position if player else Vector2(566, 335)
	var angle := TAU * float(index) / float(total) + random.randf_range(-0.22, 0.22)
	var distance := MIN_SPAWN_DISTANCE + random.randf_range(0.0, EXTRA_SPAWN_DISTANCE)
	var spawn_position := center + Vector2(cos(angle), sin(angle)) * distance
	spawn_position.x = clampf(spawn_position.x, SPAWN_MIN.x, SPAWN_MAX.x)
	spawn_position.y = clampf(spawn_position.y, SPAWN_MIN.y, SPAWN_MAX.y)
	return spawn_position

func _place_initial_enemies() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for index in enemies.size():
		enemies[index].global_position = _spawn_position(index, enemies.size())

func register_kill() -> void:
	kills += 1

func _update_wave_label() -> void:
	var label := get_node_or_null("UI/HUD/WaveLabel") as Label
	if label:
		label.text = "Волна: %d" % wave_number