extends Node2D

@export var world_size := Vector2(4800.0, 3600.0)
@export var tile_size := 32.0

var noise := FastNoiseLite.new()

func _ready() -> void:
	noise.seed = 82417
	noise.frequency = 0.035
	noise.fractal_octaves = 3
	queue_redraw()

func _draw() -> void:
	var columns := int(world_size.x / tile_size)
	var rows := int(world_size.y / tile_size)
	for y in rows:
		for x in columns:
			var sample := noise.get_noise_2d(float(x), float(y))
			var brightness := remap(sample, -1.0, 1.0, 0.78, 1.12)
			var grass_color := Color(0.16, 0.34, 0.12, 1.0) * brightness
			var rect := Rect2(Vector2(x, y) * tile_size, Vector2(tile_size + 1.0, tile_size + 1.0))
			draw_rect(rect, grass_color)

			if sample > 0.15:
				var blade_position := rect.position + Vector2(tile_size * 0.35, tile_size * 0.55)
				draw_line(blade_position, blade_position + Vector2(3.0, -7.0), Color(0.32, 0.52, 0.17, 0.7), 1.5)
