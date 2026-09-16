extends Area2D
class_name Projectile

@export var speed: float = 600.0
@export var lifetime: float = 2.0
@export var enemy_projectile: bool = false

@onready var dmg: DamageComponent = $DamageComponent
var _velocity: Vector2 = Vector2.ZERO
var _ignore: Node = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_physics_process(false)


func launch(direction: Vector2, ignore: Node = null) -> void:
	_ignore = ignore
	_velocity = direction.normalized() * speed
	rotation = _velocity.angle()
	set_physics_process(true)

	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += _velocity * delta


func _on_body_entered(body: Node) -> void:
	if body == _ignore:
		return
	if enemy_projectile and not body.is_in_group("player"):
		return
	if not enemy_projectile and body.is_in_group("player"):
		return
	if dmg:
		dmg.apply(body)
	queue_free()
