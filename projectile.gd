extends Area2D
class_name Projectile

@export var speed: float = 150
@export var lifetime: float = 2.0

@onready var dmg: DamageComponent = $DamageComponent
var _velocity: Vector2 = Vector2.ZERO

func launch(direction: Vector2) -> void:
	_velocity = direction.normalized() * speed
	
	var t = Timer.new()
	t.one_shot = true
	t.wait_time = lifetime
	t.autostart = true
	t.timeout.connect(queue_free)
	add_child(t)


func _physics_process(delta: float) -> void:
	position += _velocity * delta


func _on_body_entered(body: Node) -> void:
	if dmg:
		dmg.apply(body)
	queue_free()
