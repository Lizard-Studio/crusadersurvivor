extends CharacterBody2D

@export var speed: float = 50.0
@export var hit_cooldown = 1.0
@export var damage_amount: int = 10
@export var health: int = 30
var player: Node = null
@onready var animated_sprite := $AnimatedSprite2D

var flow_field: Node = null
var last_hit_time = 0.0
var last_side_right := true
var last_direction := Vector2.ZERO

const XP_ORB = preload("res://xporb/experience_orb.tscn")

func set_flow_field(field: Node) -> void:
	flow_field = field
	print("ff for enemy")

func _ready():
	find_player()

func find_player():
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		player = get_node_or_null("%Character")
	if player == null:
		player = get_tree().current_scene.find_child("Character", true, false)
	if player == null:
		push_error("no player")

func _physics_process(delta):
	if flow_field == null or player == null:
		return
	if not flow_field.has_method("get_direction"):
		return

	var direction = flow_field.get_direction(global_position)
	velocity = direction * speed

	prevent_sticky_collision()
	move_and_slide()
	handle_animation(direction)
	handle_damage()

func prevent_sticky_collision():
	if player == null:
		return

	var distance_to_player = global_position.distance_to(player.global_position)
	var min_distance = 35.0

	if distance_to_player < min_distance and distance_to_player > 0:
		var separation_vector = (global_position - player.global_position).normalized()
		var separation_strength = (min_distance - distance_to_player) / min_distance
		var separation_force = separation_vector * speed * 1.5 * separation_strength
		velocity += separation_force

func handle_animation(direction: Vector2):
	last_direction = direction
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_side_right = direction.x < 0
			animated_sprite.play("run_side")
			animated_sprite.flip_h = not last_side_right
		elif direction.y < 0:
			animated_sprite.play("run_back")
			animated_sprite.flip_h = false
		else:
			animated_sprite.play("run_front")
			animated_sprite.flip_h = false

func handle_damage():
	if player == null:
		return

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision and collision.get_collider():
			var collider = collision.get_collider()
			if collider == player:
				deal_damage_to_player(collider)

func deal_damage_to_player(target):
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_hit_time < hit_cooldown:
		return

	if target.has_method("take_damage"):
		last_hit_time = current_time
		target.take_damage(damage_amount)
		print("Enemy dealt ", damage_amount, " damage to player")
		
		var knockback_direction = -last_direction.normalized()
		velocity = knockback_direction * speed * 2.5
		move_and_slide()

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		die()

func die():
	spawn_xp_orb()
	queue_free()

func spawn_xp_orb():
	var xp_orb = XP_ORB.instantiate()
	xp_orb.add_to_group("xp_orb")
	xp_orb.global_position = global_position
	get_parent().add_child(xp_orb)
