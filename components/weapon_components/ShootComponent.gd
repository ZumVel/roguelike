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


func fire(target_position: Vector2) -> void:
	if not _can_fire:
		return
	if not projectile_scene:
		push_error("ShootComponent: projectile_scene not assigned")
		return
	
	var spawn_node: Node2D = get_parent() as Node2D
	if muzzle_path != ^"" and has_node(muzzle_path):
		var muzzle := get_node(muzzle_path) as Node2D
		if muzzle:
			spawn_node = muzzle
	
	var proj = projectile_scene.instantiate()
	if not proj:
		push_error("Failed to instantiate projectile")
		return
	
	proj.global_position = spawn_node.global_position
	
	if proj.has_method("launch"):
		var dir = (target_position - spawn_node.global_position).normalized()
		proj.launch(dir)
	elif proj.has_method("set_direction"):
		proj.set_direction((target_position - spawn_node.global_position).normalized())
	
	get_tree().current_scene.add_child(proj)
	
	_can_fire = false
	_timer.start()


func _on_cooldown_finished() -> void:
	_can_fire = true
