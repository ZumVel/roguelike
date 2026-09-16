extends Area2D

@export var experience_value: int = 25
@export var attraction_distance: float = 140.0
@export var attraction_speed: float = 260.0

var collected := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		player = get_tree().current_scene.get_node_or_null("SimpleCharacter") as Node2D
	if player:
		var distance := global_position.distance_to(player.global_position)
		if distance <= 24.0:
			_collect(player)
		elif distance <= attraction_distance:
			global_position = global_position.move_toward(player.global_position, attraction_speed * delta)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body.name == "SimpleCharacter":
		_collect(body)

func _collect(player: Node) -> void:
	if collected or not player.has_method("add_experience"):
		return
	collected = true
	player.add_experience(experience_value)
	queue_free()