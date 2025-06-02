extends Node2D

const DIRS = [
	Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,
	Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)
]

@export var tilemap: TileMap
@export var player: Node2D
@export var max_field_radius: int = 30

var cost_field = {}
var flow_field = {}
var update_timer := 0.0
const UPDATE_INTERVAL := 0.2

func _ready():
	assert(tilemap != null, "TileMap не назначен!")
	assert(player != null, "Игрок не назначен!")
	update_field()

func update_field():
	if !is_instance_valid(player) or !is_instance_valid(tilemap):
		return
	
	cost_field.clear()
	flow_field.clear()
	
	var start_cell = tilemap.local_to_map(player.global_position)
	var open_set = [start_cell]
	cost_field[start_cell] = 0
	
	while not open_set.is_empty():
		var current_cell = open_set.pop_front()
		
		for dir in DIRS:
			var neighbor_cell = current_cell + dir
			
			if neighbor_cell.distance_to(start_cell) > max_field_radius:
				continue
				
			if !tilemap.get_cell_tile_data(0, neighbor_cell):
				continue
				
			var new_cost = cost_field[current_cell] + 1
			if !cost_field.has(neighbor_cell) or new_cost < cost_field[neighbor_cell]:
				cost_field[neighbor_cell] = new_cost
				open_set.append(neighbor_cell)
	
	# Строим flow field
	for cell in cost_field:
		var min_cost = cost_field[cell]
		var best_dir = Vector2.ZERO
		
		for dir in DIRS:
			var neighbor = cell + dir
			if cost_field.get(neighbor, INF) < min_cost:
				min_cost = cost_field[neighbor]
				best_dir = Vector2(dir).normalized()
		
		flow_field[cell] = best_dir
	
	print("ff updater: ", start_cell, 
		  " cells: ", cost_field.size())

func get_direction(world_position: Vector2) -> Vector2:
	var cell = tilemap.local_to_map(world_position)
	if flow_field.has(cell):
		return flow_field[cell]
	
	var nearest = find_nearest_valid_cell(cell)
	if nearest != Vector2i.ZERO:
		var dir = (tilemap.map_to_local(nearest) - world_position).normalized()
		return dir * 0.5
	
	return Vector2.ZERO

func find_nearest_valid_cell(cell: Vector2i) -> Vector2i:
	var radius = 1
	var max_radius = 20
	var start_cell = tilemap.local_to_map(player.global_position)
	
	while radius <= max_radius:
		for y in range(-radius, radius + 1):
			for x in range(-radius, radius + 1):
				var check_cell = cell + Vector2i(x, y)
				if flow_field.has(check_cell) and tilemap.get_cell_tile_data(0, check_cell):
					return check_cell
		radius += 1
	
	return start_cell

func _process(delta):
	update_timer += delta
	if update_timer >= UPDATE_INTERVAL:
		update_timer = 0.0
		update_field()
