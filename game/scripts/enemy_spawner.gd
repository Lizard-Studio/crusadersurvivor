extends Node2D

@export var enemy_scene: PackedScene = preload("res://game/enemy.tscn")
@export var spawn_radius := 1200.0
@export var spawn_interval := 2.0

@onready var player := get_parent().get_node("Character")
var time_accumulator := 0.0

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= spawn_interval:
		time_accumulator = 0.0
		_maybe_spawn_enemy()


func _maybe_spawn_enemy():
	if enemy_scene == null or player == null:
		return

	if randi() % 3 != 0: #!
		return

	var enemy = enemy_scene.instantiate()

	var angle = randf() * TAU
	var distance = randf_range(spawn_radius * 0.8, spawn_radius)
	var spawn_offset = Vector2(cos(angle), sin(angle)) * distance
	enemy.set_flow_field($"../FlowField")
	enemy.global_position = player.global_position + spawn_offset

	get_tree().current_scene.add_child(enemy)
