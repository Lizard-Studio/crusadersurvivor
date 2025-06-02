extends CharacterBody2D

@export var speed: float = 60.0
@export var hit_cooldown = 1.0
@onready var player = %Character
var flow_field: Node = null
var last_hit_time = 0.0

func set_flow_field(field: Node) -> void:
	flow_field = field
	print("ff for enemy")

func _physics_process(delta):
	if flow_field == null:
		push_warning("no ff nom")
		return

	if not flow_field.has_method("get_direction"):
		push_warning("ff no get_direction!")
		return

	var direction = flow_field.get_direction(global_position)
	var tilemap = flow_field.tilemap
	var cell = tilemap.local_to_map(global_position)

	velocity = direction * speed
	move_and_slide()
	var collision = move_and_collide(velocity*delta)
	
	if collision:
		var body = collision.get_collider()
		if Time.get_ticks_msec() / 1000.0 - last_hit_time > hit_cooldown:
			if body.has_method("take_damage"):
				last_hit_time = Time.get_ticks_msec() / 1000.0
				body.take_damage(10)
		var away = (global_position - player.global_position).normalized()
		velocity += away * 200

	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	if flow_field and flow_field.tilemap and is_instance_valid(flow_field):
		var cell = flow_field.tilemap.local_to_map(global_position)
		var target_pos = global_position + velocity.normalized() * 50
		draw_line(Vector2.ZERO, (target_pos - global_position).rotated(-rotation), Color.RED, 2)
