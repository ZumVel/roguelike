extends Node
class_name ShootComponent

@export var projectile_scene: PackedScene
@export var fire_rate: float = 0.3
@export var muzzle_path: NodePath = ^""

var _can_fire := true
var _timer: Timer = null

func _ready() -> void:
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = fire_rate
	_timer.timeout.connect(_on_cooldown_finished)
	add_child(_timer)


## Returns true if a projectile was actually spawned.
func fire(target_position: Vector2) -> bool:
	if not _can_fire:
		return false
	if not projectile_scene:
		push_error("ShootComponent: projectile_scene not assigned")
		return false

	var spawn_node: Node2D = get_parent() as Node2D
	if muzzle_path != ^"":
		var muzzle := get_node_or_null(muzzle_path) as Node2D
		if muzzle == null and get_parent():
			muzzle = get_parent().get_node_or_null("muzzle") as Node2D
		if muzzle:
			spawn_node = muzzle

	var proj = projectile_scene.instantiate()
	if not proj:
		push_error("Failed to instantiate projectile")
		return false

	var host := get_tree().current_scene
	if host == null:
		host = get_tree().root
	host.add_child(proj)

	proj.global_position = spawn_node.global_position

	var shooter: Node = get_parent()
	while shooter and not (shooter is CharacterBody2D):
		shooter = shooter.get_parent()

	var dir := (target_position - spawn_node.global_position).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT.rotated(spawn_node.global_rotation)

	if proj.has_method("launch"):
		proj.launch(dir, shooter)
	elif proj.has_method("set_direction"):
		proj.set_direction(dir)

	_can_fire = false
	_timer.start()
	return true


func _on_cooldown_finished() -> void:
	_can_fire = true
