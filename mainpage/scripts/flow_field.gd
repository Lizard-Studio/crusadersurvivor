extends Node2D

const DIRS = [
	Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN,
	Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)
]

@export var tilemap: TileMap
@export var player: Node2D

var cost_field = {}
var flow_field = {}

func _ready():
	update_field()

func update_field():
	cost_field.clear()
	flow_field.clear()
	
	var open_set = [player.global_position]
	var start_cell = tilemap.local_to_map(player.global_position)
	cost_field[start_cell] = 0

	while not open_set.is_empty():
		var current_pos = open_set.pop_front()
		var current_cell = tilemap.local_to_map(current_pos)
		var current_cost = cost_field.get(current_cell, INF)

		for dir in DIRS:
			var neighbor_cell = current_cell + dir
			if not tilemap.get_cell_tile_data(0, neighbor_cell):
				continue  # Непроходимо
			
			if cost_field.has(neighbor_cell):
				continue  # Уже посещено

			cost_field[neighbor_cell] = current_cost + 1
			open_set.append(tilemap.map_to_local(neighbor_cell))
	
	# Теперь создаём FlowField
	for cell in cost_field:
		var min_cost = cost_field[cell]
		var best_dir = Vector2.ZERO
		for dir in DIRS:
			var neighbor = cell + dir
			if cost_field.has(neighbor) and cost_field[neighbor] < min_cost:
				min_cost = cost_field[neighbor]
				best_dir = (tilemap.map_to_local(neighbor) - tilemap.map_to_local(cell)).normalized()
		flow_field[cell] = best_dir

func get_direction(world_position: Vector2) -> Vector2:
	var cell = tilemap.local_to_map(world_position)
	return flow_field.get(cell, Vector2.ZERO)
