extends CharacterBody2D

@export var speed: float = 77.0
@export var is_shooter: bool = false
@export var contact_distance: float = 100.0
@export var contact_damage: int = 10
@export var attack_cooldown: float = 0.8
@export var shoot_distance: float = 260.0
@export var projectile_speed: float = 280.0
@onready var health_component: Node = $HealthComponent

const PROJECTILE_SCENE := preload("res://projectile.tscn")
var target: Node2D
var attack_time_left := 0.0

func _ready() -> void:
	add_to_group("enemies")
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_update_health_bar)
	_update_health_bar(health_component.current_health, health_component.max_health)
	if is_shooter:
		$Visual.modulate = Color(0.8, 0.25, 0.9, 1.0)

func _physics_process(delta: float) -> void:
	attack_time_left = max(attack_time_left - delta, 0.0)
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D
		if not target:
			target = get_tree().current_scene.get_node_or_null("SimpleCharacter") as Node2D
	if target:
		var distance := global_position.distance_to(target.global_position)
		if is_shooter and distance <= shoot_distance:
			velocity = Vector2.ZERO
			_try_attack_target()
		elif distance > contact_distance:
			velocity = global_position.direction_to(target.global_position) * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			_try_attack_target()

func _try_attack_target() -> void:
	if attack_time_left > 0.0:
		return

	if is_shooter and global_position.distance_to(target.global_position) <= shoot_distance:
		var projectile := PROJECTILE_SCENE.instantiate()
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = global_position
		projectile.speed = projectile_speed
		projectile.enemy_projectile = true
		projectile.launch(global_position.direction_to(target.global_position), self)
		attack_time_left = attack_cooldown
		return

	var target_health := target.get_node_or_null("HealthComponent") as Node
	if target_health and target_health.has_method("receive_damage"):
		target_health.receive_damage(contact_damage)
		attack_time_left = attack_cooldown

func _update_health_bar(current: int, maximum: int) -> void:
	var bar := get_node_or_null("HealthBar") as ProgressBar
	if bar:
		bar.max_value = maximum
		bar.value = current

func _on_died() -> void:
	var main := get_tree().current_scene
	if main and main.has_method("register_kill"):
		main.register_kill()
	var pickup_scene: PackedScene = preload("res://collectibles/experience_pickup.tscn")
	var pickup := pickup_scene.instantiate()
	get_tree().current_scene.add_child(pickup)
	pickup.global_position = global_position
	queue_free()